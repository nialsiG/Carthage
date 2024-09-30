class_name NightScreen extends Control

const enums = preload("res://Singletons/enums.gd")

@onready var monkey_faces: MonkeyFaces = $ColorRect/VBoxContainer/MonkeyFaces
@onready var end_button: Button = $ColorRect/EndNightButton

signal EndNight()

func _ready():
	end_button.grab_focus()
	ColobsManager.dead_monkeys_list.connect(OnDeadMonkeysPublished)

func OnDeadMonkeysPublished(deadMonkeys : Array[Monkey], reasons : Array[enums.PickableType]):
	if (deadMonkeys.size() == 0):
		monkey_faces.hide()
		$ColorRect/VBoxContainer/Label.text = "La nuit est tombée...\nTous les singes ont pu manger à leur faim. Tous ont survécu !"
	else:
		if deadMonkeys.size() == 1:
			$ColorRect/VBoxContainer/Label.text = "La nuit est tombée...\nLa nourriture a manqué. Un singe est mort..."
		else:
			$ColorRect/VBoxContainer/Label.text = "La nuit est tombée...\nLa nourriture a manqué. "+str(deadMonkeys.size())+" singes sont morts..."
		monkey_faces.Update(deadMonkeys) 
		monkey_faces.show()


func _on_end_night_button_pressed():
	EndNight.emit()
	get_tree().paused = false
