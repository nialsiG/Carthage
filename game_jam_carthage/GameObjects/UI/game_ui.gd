class_name GameUi extends Control

@onready var monkey_faces: MonkeyFaces = $MarginContainer/MonkeyFaces
@onready var monkey = preload("res://GameObjects/Animals/Monkey.tscn")

@export var monkeys: Array[Monkey]

func _ready():
	var new_monkey = monkey.instantiate()
	add_child(new_monkey)
	monkeys.append(new_monkey)
	print(monkeys)
	UpdateMonkeyFaces(monkeys)

func UpdateMonkeyFaces(monkeys: Array[Monkey]):
	monkey_faces.Update(monkeys)
