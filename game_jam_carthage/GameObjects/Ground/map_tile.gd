extends StaticBody3D
class_name MapTile

var _coords : Vector2 = Vector2(0,0)
var _gameScreen : GameScreen

@onready var _mesh : CSGBox3D = $Mesh
@onready var _selectionMesh : CSGBox3D = $Selected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Initialize(gameScreen : GameScreen, coordinates : Vector2, material : StandardMaterial3D):
	_gameScreen = gameScreen
	_coords = coordinates
	_mesh.material = material
	print("tile: " +str(_coords))

func _on_input_event(camera, event, event_position, normal, shape_idx):
	if(_gameScreen.TryGrabFocus(self)):
		_selectionMesh.show()
		print("FocusedTile "+str(_coords))

func ReleaseFocus():
	_selectionMesh.hide()
	
func GetTile() -> Vector2:
	return _coords
