class_name NightScreen extends Control

@onready var monkey_faces: MonkeyFaces = $ColorRect/VBoxContainer/MonkeyFaces
@onready var end_button: Button = $ColorRect/EndNightButton

signal EndNight()

func _ready():
	end_button.grab_focus()

func _on_end_night_button_pressed():
	EndNight.emit()
	get_tree().paused = false
