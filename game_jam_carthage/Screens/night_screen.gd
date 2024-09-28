class_name NightScreen extends Control

@onready var monkey_faces = $ColorRect/VBoxContainer/MonkeyFaces

signal EndNight()

func _on_end_night_button_pressed():
	EndNight.emit()
	get_tree().paused = false
