extends Node3D
class_name MapItem

const enums = preload("res://Singletons/enums.gd")

var _tile : MapTile

func SetTile(tile : MapTile):
	if (_tile != null):
		_tile.LeaveTile(self)
	_tile = tile
	if(_tile == null):
		print(str(_tile))
	_tile.EnterTile(self)
	print(str(position)+" "+str(_tile.GetTile()))
	
func SetMultipleTiles(tiles : Array[MapTile]):
	for tile in tiles:
		tile.EnterTile(self)

func GetTile() -> MapTile:
	return _tile

func GetTilePosition() -> Vector2 :
	return _tile.GetTile()

var _isMoving : bool = false
@onready var _targetPosition : Vector3 = position
var _currentPosition : Vector3 = position

func _process(delta : float):
	if (!_isMoving):
		return
		
	position += (_targetPosition - _currentPosition) * delta * 4
	if((_targetPosition - position).length() < 0.1):
		position = _targetPosition
		_currentPosition = _targetPosition
		_isMoving = false 

func Move(targetPosition : Vector3):
	_currentPosition = position
	_targetPosition = targetPosition
	_isMoving = true

func InterruptMovement():
	_isMoving = false
