class_name MonkeyFace extends Control

const _enums = preload("res://Singletons/enums.gd")

# some variables to store monkey information
@onready var monkey: Monkey

@onready var leaf_sprite = $HBoxContainer/Sprite2DLeaf
@onready var fruit_sprite = $HBoxContainer/Sprite2DFruit
@onready var herb_sprite = $HBoxContainer/Sprite2DHerb
@onready var context_panel = $ContextPanel
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

func DisplayHerb(display: bool = true):
	Display(herb_sprite, display)

func Display(object: TextureRect, display: bool = true):
	if display:
		object.show()
	else:
		object.hide()

func Update():
	richText.clear()
	update_asset(monkey._asset)
	if monkey.IsLeader():
		richText.add_text("Leader")
	richText.add_text("\nAlimentation :")
	if monkey._diet.has(_enums.PickableType.LEAF):
		richText.add_text(" Feuilles")
	if monkey._diet.has(_enums.PickableType.FRUIT):
		richText.add_text(" Fruits")
	if monkey._diet.has(_enums.PickableType.GRAIN):
		richText.add_text(" Herbes")
	richText.add_text("\nVitesse : " + str(monkey._move_pattern))
	richText.add_text("\nCapacités :")
	if monkey._locomotion == _enums.LocomotionType.ARBOREAL:
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
