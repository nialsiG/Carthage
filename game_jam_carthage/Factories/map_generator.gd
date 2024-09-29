extends Node
class_name MapGenerator

const enums = preload("res://Singletons/enums.gd")

var tilePS = preload("res://GameObjects/Ground/MapTile.tscn")
var mapPS = preload("res://GameObjects/Ground/Map.tscn")
var baseMaterial = preload("res://Assets/Materials/DefaultGround.tres")
var forestMaterial = preload("res://Assets/Materials/ForestGround.tres")
var brackishMaterial = preload("res://Assets/Materials/BrackishGround.tres")
var savannahMaterial = preload("res://Assets/Materials/SavannahGround.tres")



@onready var _monkeyGenerator : MonkeyGenerator = $MonkeyGenerator
@onready var _pickableFactory : PickableFactory = $PickableFactory
@onready var _obstacleFactory : ObstacleFactory = $ObstacleFactory
@onready var _enemyFactory : EnemyFactory = $EnemyFactory

func GenerateMap(gameScreen : GameScreen, dimensions : Vector2):
	
	GenerateMapFromJson(gameScreen, )
	var map = mapPS.instantiate() as Map
	var width = int(dimensions.x)
	var height = int(dimensions.y)
	var takenPositions : Array[Vector2] = [Vector2(- (width / 2) + 1, - (height / 2) + 1),
	Vector2((width / 2) + 1, - (height / 2) + 1),
	Vector2((width / 2) + 1, (height / 2) + 1),
	Vector2(- (width / 2) + 1, (height / 2) + 1)]
	var obstacleArrays : Array[enums.ObstableType] = [enums.ObstableType.ROCK, enums.ObstableType.TREE]
	
	GenerateTiles(map, width, height, gameScreen)
			
	#Generate pickables
	for i in 10:
		var position = GenerateNonTakenPosition(takenPositions, dimensions - Vector2.ONE)
		var pickableType = ColobsManager.GetPickableForBiome()
		GeneratePickable(map, pickableType, position)

	#Generate obstacles
	for i in 10:
		var position = GenerateNonTakenPosition(takenPositions, dimensions)
		var obstacleType = obstacleArrays.pick_random()
		GenerateObstacle(map, obstacleType, position)
	
	# Generate Monkeys
	for i in 2:
		var position = GenerateNonTakenPosition(takenPositions, dimensions - Vector2.ONE)
		GenerateMonkey(map, position)

	# Generate Predators
	for i in 2:
		var position = GenerateNonTakenPosition(takenPositions, dimensions - 3 * Vector2.ONE)
		var enemy = _enemyFactory.GenerateEnemy(enums.Enemies.REDPANDA)
		map.AddPredator(enemy, position)

	return map

func GenerateTiles(map : Map, width : int, height : int, gameScreen : GameScreen):
	for x in width:
		for y in height:
			var tile = tilePS.instantiate()
			map.AddTile(tile)
			var position = Vector2(x - (width / 2) + 1, y - (height / 2) + 1)
			var material : StandardMaterial3D = baseMaterial
			if (x == 0):
				material = GetMaterialByBiome(ColobsManager.GetSurroundingBiome(enums.PositionOnMap.LEFT))
			elif (x == width - 1):
				material = GetMaterialByBiome(ColobsManager.GetSurroundingBiome(enums.PositionOnMap.RIGHT))
			elif (y == 0):
				material = GetMaterialByBiome(ColobsManager.GetSurroundingBiome(enums.PositionOnMap.UP))
			elif (y== height -1):
				material = GetMaterialByBiome(ColobsManager.GetSurroundingBiome(enums.PositionOnMap.DOWN))
			else:
				material = GetMaterialByBiome(ColobsManager.GetSurroundingBiome(enums.PositionOnMap.MIDDLE))
			tile.Initialize(gameScreen, position, material)
			tile.position = Vector3(x + 0.5 - width / 2, 0, y + 0.5 - height / 2)
			
func GenerateObstacle(map : Map, obstacleType : enums.ObstableType, position : Vector2):
	var obstacle =_obstacleFactory.CreateScene(obstacleType, ColobsManager.GetCurrentBiome())
	map.AddObstacle(obstacle, position)

func GenerateMonkey(map : Map, position : Vector2):
		var monkey = _monkeyGenerator.GenerateMonkey()
		map.AddStray(monkey, position)

func GeneratePickable(map : Map, pickableType : enums.PickableType, position : Vector2):
	var pickable = _pickableFactory.CreateScene(pickableType)
	map.AddPickable(pickable, position)

func GeneratePredator(map: Map, predatorType : enums.Enemies, position : Vector2, patterns : Array[Vector3]):
		var enemy = _enemyFactory.GenerateEnemy(predatorType) as Ennemy
		enemy._move_pattern = patterns
		map.AddPredator(enemy, position)

func GenerateNonTakenPosition(takenPositions : Array[Vector2], dimensions : Vector2) -> Vector2:
	var x = randi_range(-dimensions.x / 2 + 1, dimensions.x / 2)
	var y = randi_range(-dimensions.y / 2 + 1, dimensions.y / 2)

	while(CheckAlreadyOccupied(takenPositions, x, y)):
		x = randi_range(-dimensions.x / 2 + 1, dimensions.x / 2)
		y = randi_range(-dimensions.y / 2 + 1, dimensions.y / 2)

	var position = Vector2(x, y)
	takenPositions.append(position)
	return position

func CheckAlreadyOccupied(takenPositions : Array[Vector2], x : int, y : int) -> bool:
	for pos in takenPositions:
		if pos.x == x && pos.y == y:
			return true
	return false

func GetMaterialByBiome(biome : enums.BiomeType) -> StandardMaterial3D:
	match(biome):
		enums.BiomeType.FOREST:
			return forestMaterial
		enums.BiomeType.SAVANNAH:
			return savannahMaterial
		enums.BiomeType.BRACKISH:
			return brackishMaterial
		_:
			return baseMaterial
	

func GenerateMapFromJson(gameScreen : GameScreen):
	var json_as_text = FileAccess.get_file_as_string("res://Assets/Levels/LevelModel.json")
	var dico :Dictionary = JSON.parse_string(json_as_text)
	var width = dico["Map"]["x"]
	var height = dico["Map"]["y"]
	var dimensions = Vector2(width, height)
	var map = mapPS.instantiate() as Map
	GenerateTiles(map, dimensions.x, dimensions.y, gameScreen)
	var monkeys = dico["Monkeys"]
	for monkey in monkeys:
		var x = monkey["x"]
		var y = monkey["y"]
		GenerateMonkey(map, Vector2(x,y))
	
	var obstacles = dico["Obstacles"]
	for obstacle in obstacles:
		var x = obstacle["x"]
		var y = obstacle["y"]
		var obstacleType = obstacle["type"] as enums.ObstableType
		GenerateObstacle(map, obstacleType, Vector2(x, y))

	var pickables = dico["Consumables"]
	for pickable in pickables:
		var x = pickable["x"]
		var y = pickable["y"]
		var pickableType = pickable["type"] as enums.PickableType
		GeneratePickable(map, pickableType, Vector2(x, y))
	
	var predators = dico["Enemies"]
	for predator in predators:
		var x = predator["x"]
		var y = predator["y"]
		var predatorType = predator["type"] as enums.Enemies
		var moveSets = predator["patterns"]
		var patterns : Array[Vector3] = []
		for pattern in moveSets:
			patterns.append(Vector3(pattern[0], 0, pattern[1]))
		GeneratePredator(map, predatorType, Vector2(x, y), patterns)
