class_name MonkeyFace extends TextureRect

const _enums = preload("res://Singletons/enums.gd")

# some variables to store monkey information
@onready var monkey: Monkey

@onready var leaf_sprite = $HBoxContainer/Sprite2DLeaf
@onready var fruit_sprite = $HBoxContainer/Sprite2DFruit
@onready var grain_sprite = $HBoxContainer/Sprite2DGrain
@onready var context_panel = $ContextPanel
@onready var nameLabel = $NameLabel
@onready var richText = $ContextPanel/MarginContainer/RichTextLabel

var array_faces = [
	"res://Assets/Sprites/monkey/face1.png",
	"res://Assets/Sprites/monkey/face2.png",
	"res://Assets/Sprites/monkey/face3.png"
]


func DisplayLeaf(display: bool = true):
	Display(leaf_sprite, display)
 
func DisplayFruit(display: bool = true):
	Display(fruit_sprite, display)

func DisplayGrain(display: bool = true):
	Display(grain_sprite, display)

func Display(object: TextureRect, display: bool = true):
	if display:
		object.show()
	else:
		object.hide()

func Update():
	richText.clear()
	if monkey.IsLeader():
		richText.add_text("Leader")
	richText.add_text("\nAlimentation :")
	if monkey._diet.has(_enums.PickableType.LEAF):
		richText.add_text(" Feuilles")
	if monkey._diet.has(_enums.PickableType.FRUIT):
		richText.add_text(" Fruits")
	if monkey._diet.has(_enums.PickableType.GRAIN):
		richText.add_text(" Graines")
	if monkey._locomotion == _enums.LocomotionType.ARBOREAL:
		richText.add_text("\nCapacités :")
		richText.add_text("\n - Arboricole (peut franchir les Arbres)")

func _on_mouse_entered():
	var mouse_position = get_viewport().get_mouse_position()
	context_panel.show()
	context_panel.position = mouse_position
	Update()

func _on_mouse_exited():
	context_panel.hide()
	
func update_asset(asset: int):
	$".".texture = load(array_faces[asset])

func SetMonkey(assignedMonkey : Monkey):
	monkey = assignedMonkey
	nameLabel.text = monkey.Name
	update_asset(assignedMonkey._asset)
	# Diet:
	DisplayLeaf(monkey._diet.has(_enums.PickableType.LEAF))
	DisplayFruit(monkey._diet.has(_enums.PickableType.FRUIT))
	DisplayGrain(monkey._diet.has(_enums.PickableType.GRAIN))
