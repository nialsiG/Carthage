extends Node3D
class_name MapItem

var _tile : MapTile

func SetTile(tile : MapTile):
	_tile = tile
	
func GetTile() -> MapTile:
	return _tile

func GetTilePosition() -> Vector2 :
	return _tile.GetTile()
