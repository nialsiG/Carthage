class_name MonkeyFace extends TextureRect

# some variables to store monkey information
@onready var monkey: Monkey

@onready var leaf_sprite = $HBoxContainer/Sprite2DLeaf
@onready var fruit_sprite = $HBoxContainer/Sprite2DFruit
@onready var herb_sprite = $HBoxContainer/Sprite2DHerb
@onready var context_panel = $ContextPanel
@onready var richText = $ContextPanel/MarginContainer/RichTextLabel

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
	#if monkey.IsLeader():
	if true:
		richText.add_text("Leader")
	richText.add_text("\nAlimentation :")
	richText.add_text("\nVitesse :")
	richText.add_text("\nCapacités :")

func _on_mouse_entered():
	var mouse_position = get_viewport().get_mouse_position()
	context_panel.show()
	context_panel.position = mouse_position
	Update()

func _on_mouse_exited():
	context_panel.hide()
