extends CanvasLayer

@onready var game_scene =  "res://Screens/StartScreen.tscn"

func _ready():
	SoundsettingsManager.Win()
	var monkeys = ColobsManager.PullMonkeys()
	$MarginContainer/VBoxContainer/RemainingMonkeys.text = "Singes survivants: "+ str(monkeys.size())
	$MarginContainer/VBoxContainer/DeadMonkeysFromFood.text = "Singes morts de faim: "+ str(ColobsManager._deadMonkeysFromFood)
	$MarginContainer/VBoxContainer/DeadMonkeysFromBeasts.text = "Singes mangés par les prédateurs: "+ str(ColobsManager._deadMonkeysFromBeast)
	$MarginContainer/VBoxContainer/GatheredFoodLabel.text = "Nourriture ramassée: "+ str(ColobsManager._pickedFood)

func _on_canvas_layer_pressed():
	get_tree().change_scene_to_file(game_scene)	
