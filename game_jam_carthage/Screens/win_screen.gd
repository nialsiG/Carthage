extends CanvasLayer

@onready var game_scene =  "res://Screens/StartScreen.tscn"

func _ready():
	SoundsettingsManager.Win()

func _on_canvas_layer_pressed():
	get_tree().change_scene_to_file(game_scene)	
