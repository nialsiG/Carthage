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
	
func GetTile() -> MapTile:
	return _tile

func GetTilePosition() -> Vector2 :
	return _tile.GetTile()
