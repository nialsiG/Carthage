extends Node3D
class_name Map

var _tiles : Array[MapTile] = []
var _pickables : Array[Pickable] = []
var _obstacles : Array[Obstacle] = []
var _strays : Array[Monkey] = []
var _predators : Array[Ennemy] = []

var dimensions : Vector2

@onready var _tilesNode : Node3D = $Tiles
@onready var _obstaclesNode : Node3D = $Obstacles
@onready var _pickablesNode : Node3D = $Pickables
@onready var _strayNode : Node3D = $Strays
@onready var _predatorNode : Node3D = $Predators

func _ready():
	for tile in _tiles: 
		_tilesNode.add_child(tile)
	
	for pickable in _pickables:
		_pickablesNode.add_child(pickable)
		
	for obstacle in _obstacles:
		_obstaclesNode.add_child(obstacle)
		
	for stray in _strays:
		_strayNode.add_child(stray)

	for predator in _predators:
		_predatorNode.add_child(predator)
		
func AddTile(tile : MapTile):
	_tiles.append(tile)

func AddPickable(pickable : Pickable, position : Vector2):
	_pickables.append(pickable)
	pickable.position = Vector3(position.x, 0, position.y)
	pickable.SetTile(GetTile(position.x, position.y))

func AddStray(stray : Monkey, position : Vector2):
	_strays.append(stray)
	stray.position = Vector3(position.x, 0, position.y)
	stray.SetTile(GetTile(position.x, position.y))

func AddPredator(predator : Ennemy, position : Vector2):
	_predators.append(predator)
	predator.position = Vector3(position.x, 0, position.y)
	predator.SetTile(GetTile(position.x, position.y))

func AddObstacle(obstacle : Obstacle, position : Vector2):
	_obstacles.append(obstacle)
	obstacle.position = Vector3(position.x, 0, position.y)
	var tile = GetTile(position.x, position.y)
	obstacle.SetTile(tile)
	print("Add obstacle: "+str(obstacle.position)+" "+str(tile.GetTile()))

func AddBigObstacle(obstacle : Obstacle, position : Vector2, size : Vector2):
	_obstacles.append(obstacle)
	obstacle.position = Vector3(position.x, 0, position.y)
	var tiles : Array[MapTile] = []
	for x in size.x:
		for y in size.y:
			tiles.append(GetTile(position.x + x, position.y + y))
	obstacle.SetMultipleTiles(tiles)

func GetTile(x : float, y : float):
	for tile in _tiles:
		var coords = tile.GetTile()
		if (coords.x == x && coords.y == y):
			return tile
	return null

func GetTilefromVec(position : Vector2):
	return GetTile(round(position.x), round(position.y))

func GetPickables() -> Array[Pickable]:
	return _pickables

func GetStrays() -> Array[Monkey]:
	return _strays
	
func GetEnemies() -> Array[Ennemy]:
	return _predators
