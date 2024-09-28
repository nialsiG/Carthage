class_name GameUi extends Control

const _enums = preload("res://Singletons/enums.gd")

@onready var monkey_faces: MonkeyFaces = $MarginContainer/MonkeyFaces
@onready var monkey = preload("res://GameObjects/Animals/Monkey.tscn")
@onready var turn_counter = $MarginContainer/TurnCounter

@export var monkeys: Array[Monkey]

func _ready():
	# monkeys
	var new_monkey = monkey.instantiate()
	add_child(new_monkey)
	monkeys.append(new_monkey)
	print(monkeys)
	UpdateMonkeyFaces(monkeys)
	# period / counter
	UpdateTurnCounter(1)
	UpdatePeriod(_enums.PeriodType.TORTONIAN)

func UpdateMonkeyFaces(monkeys: Array[Monkey]):
	monkey_faces.Update(monkeys)

func UpdateTurnCounter(amount: int):
	turn_counter.UpdateTurn(amount)

func UpdatePeriod(period: _enums.PeriodType):
	turn_counter.ChangePeriod(period)
