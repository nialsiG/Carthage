class_name GameUi extends Control

const _enums = preload("res://Singletons/enums.gd")
signal NightEnd()

@onready var monkey_faces: MonkeyFaces = $MarginContainer/MonkeyFaces
@onready var monkey = preload("res://GameObjects/Animals/Monkey.tscn")
@onready var turn_counter = $MarginContainer/TurnCounter

@onready var leaf_counter = %leaf_food_counter
@onready var fruit_counter = %fruit_food_counter
@onready var herb_counter = %herb_food_counter
@onready var night_screen = $NightScreen

@export var monkeys: Array[Monkey]

func _ready():
	night_screen.connect("EndNight", OnNightEnd)

func UpdateMonkeyFaces(monkeys: Array[Monkey]):
	monkey_faces.Update(monkeys)

func UpdateTurnCounter(amount: int):
	turn_counter.UpdateTurn(amount)

func UpdatePeriod(period: _enums.PeriodType):
	turn_counter.ChangePeriod(period)

func UpdateFood(type: _enums.PickableType, amount: int):
	match type:
		_enums.PickableType.LEAF:
			leaf_counter.UpdateCounter(amount)
		_enums.PickableType.FRUIT:
			fruit_counter.UpdateCounter(amount)
		_enums.PickableType.GRAIN:
			herb_counter.UpdateCounter(amount)

func DisplayNightScreen():
	night_screen.show()
	night_screen.end_button.grab_focus()

func OnNightEnd():
	night_screen.hide()
	NightEnd.emit()
