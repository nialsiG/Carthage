class_name GameUi extends Control

const _enums = preload("res://Singletons/enums.gd")
const start_menu : String = "res://Screens/StartScreen.tscn"
signal NightEnd()

@onready var monkey_faces: MonkeyFaces = $MarginContainer/MonkeyFaces
@onready var monkey = preload("res://GameObjects/Animals/Monkey.tscn")
@onready var turn_counter = $MarginContainer/TurnCounter

@onready var leaf_counter = %leaf_food_counter
@onready var fruit_counter = %fruit_food_counter
@onready var herb_counter = %herb_food_counter
@onready var night_screen = $NightScreen
@onready var game_over_screen = $GameOverScreen
@onready var back_to_menu_betton = %BackToMenuButton

@export var monkeys: Array[Monkey]

func _ready():
	night_screen.connect("EndNight", OnNightEnd)
	ColobsManager.connect("FoodPicked", UpdateFood)

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

func GameOverScreen():
	game_over_screen.show()
	back_to_menu_betton.grab_focus()
	get_tree().paused = true

func _on_back_to_menu_button_pressed():
	var tree = get_tree()
	tree.paused = false
	tree.change_scene_to_file(start_menu)
