extends Node
class_name StartScreen

@onready var start_button: TextureButton = %StartButton
@onready var wiki_button: TextureButton = %WikiButton
@onready var game_scene =  "res://Screens/GameScreen.tscn"

func _ready():
	start_button.grab_focus()
	SoundsettingsManager.Start()

func _on_start_button_pressed():
	get_tree().change_scene_to_file(game_scene)

func _on_wiki_button_pressed():
	#TODO Display wiki panel
	pass # Replace with function body.
