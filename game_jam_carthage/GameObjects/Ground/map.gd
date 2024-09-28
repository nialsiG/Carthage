extends Node3D
class_name Map

var _tiles : Array[MapTile] = []
var _pickables : Array[Pickable] = []
var _obstacles : Array[Obstacle] = []

@onready var _tilesNode : Node3D = $Tiles
@onready var _obstaclesNode : Node3D = $Obstacles
@onready var _pickablesNode : Node3D = $Pickables

func _ready():
	for tile in _tiles: 
		_tilesNode.add_child(tile)
	
	for pickable in _pickables:
		_pickablesNode.add_child(pickable)
		
	for obstacle in _obstacles:
		_obstaclesNode.add_child(obstacle)

func AddTile(tile : MapTile):
	_tiles.append(tile)

func AddPickable(pickable : Pickable, position : Vector2):
	_pickables.append(pickable)
	pickable.position = Vector3(position.x + 0.5, 0, position.y + 0.5)
	pickable.SetTile(GetTile(position.x, position.y))


func AddObstacle(obstacle : Obstacle, position : Vector2):
	_obstacles.append(obstacle)
	obstacle.position = Vector3(position.x + 0.5, 0, position.y + 0.5)
	var tile = GetTile(position.x, position.y)
	obstacle.SetTile(tile)
	print("Add obstacle: "+str(obstacle.position)+" "+str(tile.GetTile()))

func GetTile(x : float, y : float):
	for tile in _tiles:
		var coords = tile.GetTile()
		if (coords.x == x && coords.y == y):
			return tile
	return null

func GetTilefromVec(position : Vector2):
	return GetTile(position.x, position.y)
	
func GetPickables():
	return _pickables
