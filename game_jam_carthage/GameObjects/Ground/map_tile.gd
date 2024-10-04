extends StaticBody3D
class_name MapTile

const enums = preload("res://Singletons/enums.gd")

var _coords : Vector2 = Vector2(0,0)
var _gameScreen : GameScreen
var _mapItems : Array[MapItem]
var _material : Material

@onready var _mesh : CSGBox3D = $Mesh
@onready var _selectionMesh : CSGBox3D = $Selected

var _obstructionType : enums.ObstableType

var _isBorder : bool = false
 
# Called when the node enters the scene tree for the first time.
func _ready():
	_mesh.material = _material

func Initialize(gameScreen : GameScreen, coordinates : Vector2, material : Material, isBorder: bool):
	_gameScreen = gameScreen
	_coords = coordinates
	_material = material
	_isBorder = isBorder
	print("tile: " +str(_coords))

func _on_input_event(camera, event, event_position, normal, shape_idx):
	if(_gameScreen.TryGrabFocus(self)):
		_selectionMesh.show()
		print("FocusedTile "+str(_coords))

func ReleaseFocus():
	_selectionMesh.hide()
	
func GetTile() -> Vector2:
	return _coords
	
func EnterTile(mapItem : MapItem):
	_mapItems.append(mapItem)

func GetObstructionType() -> enums.ObstableType:
	if (_mapItems.size() == 0):
		return enums.ObstableType.NONE
	
	for item in _mapItems:
		if item is Obstacle:			
			return item.obstacle_type

		if item is Monkey:
			return enums.ObstableType.MONKEY

		if (item is Ennemy):
			return enums.ObstableType.PREDATOR
			
	return enums.ObstableType.NONE
	
func LeaveTile(mapItem : MapItem):
	var index = _mapItems.find(mapItem)
	if (index >= 0):
		_mapItems.remove_at(index)
		
func GetMapItems():
	return _mapItems

func IsBorder() -> bool:
	return _isBorder
