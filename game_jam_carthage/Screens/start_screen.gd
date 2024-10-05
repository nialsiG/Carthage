extends Node
class_name StartScreen

@onready var start_button: TextureButton = %StartButton
@onready var wiki_button: TextureButton = %WikiButton
@onready var wiki_screen = $CanvasLayer/Wiki
@onready var game_scene =  "res://Screens/GameScreen.tscn"

func _ready():
	start_button.grab_focus()
	SoundsettingsManager.Start()
	wiki_screen.CloseWiki.connect(_on_wiki_return_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file(game_scene)

func _on_wiki_button_pressed():
	wiki_screen.show()
	wiki_screen.GrabFocus()

func _on_wiki_return_button_pressed():
	wiki_screen.hide()
	start_button.grab_focus()
