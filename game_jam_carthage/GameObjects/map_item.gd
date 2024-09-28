extends Node3D
class_name MapItem

var _tile : MapTile

func SetTile(tile : MapTile):
	if (_tile != null):
		_tile.LeaveTile(self)
	_tile = tile
	_tile.EnterTile(self)
	print(str(position)+" "+str(_tile.GetTile()))
	
func GetTile() -> MapTile:
	return _tile

func GetTilePosition() -> Vector2 :
	return _tile.GetTile()
