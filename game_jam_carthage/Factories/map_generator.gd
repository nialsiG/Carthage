extends Node
class_name MapGenerator

var tilePS = preload("res://GameObjects/Ground/MapTile.tscn")
var mapPS = preload("res://GameObjects/Ground/Map.tscn")
var baseMaterial = preload("res://Assets/Materials/DefaultGround.tres")
var obstaclePS = preload("res://GameObjects/Obstacle.tscn")
var pickablePS = preload("res://GameObjects/pickable.tscn")

@onready var _monkeyGenerator : MonkeyGenerator = $MonkeyGenerator

func GenerateMap(gameScreen : GameScreen, dimensions : Vector2):
	var map = mapPS.instantiate() as Map
	var width = int(dimensions.x)
	var height = int(dimensions.y)
	var takenPositions : Array[Vector2] = [Vector2(- (width / 2) + 1, - (height / 2) + 1),
	Vector2((width / 2) + 1, - (height / 2) + 1),
	Vector2((width / 2) + 1, (height / 2) + 1),
	Vector2(- (width / 2) + 1, (height / 2) + 1)]
	
	for x in width:
		for y in height:
			var tile = tilePS.instantiate()
			map.AddTile(tile)
			var position = Vector2(x - (width / 2) + 1, y - (height / 2) + 1)
			tile.Initialize(gameScreen, position, baseMaterial)
			tile.position = Vector3(x + 0.5 - width / 2, 0, y + 0.5 - height / 2)
			
	#Generate pickables
	for i in 5:
		var position = GenerateNonTakenPosition(takenPositions, dimensions)
		var pickable = pickablePS.instantiate()
		map.AddPickable(pickable, position)

	#Generate obstacles
	for i in 5:
		var position = GenerateNonTakenPosition(takenPositions, dimensions)
		var obstacle = obstaclePS.instantiate()
		map.AddObstacle(obstacle, position)
	
	# Generate Monkeys
	for i in 2:
		var position = GenerateNonTakenPosition(takenPositions, dimensions)
		var monkey = _monkeyGenerator.GenerateMonkey()
		map.AddStray(monkey, position)

	# Generate Predators
	for i in 0:
		var position = GenerateNonTakenPosition(takenPositions, dimensions)
		var obstacle = obstaclePS.instantiate()
		map.AddObstacle(obstacle, position)

	return map
	
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
