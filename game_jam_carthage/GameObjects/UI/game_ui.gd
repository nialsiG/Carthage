class_name GameUi extends Control

@onready var monkey_faces: MonkeyFaces = $MarginContainer/MonkeyFaces

func UpdateMonkeyFaces(monkeys: Array[Monkey]):
	monkey_faces.Update(monkeys)
