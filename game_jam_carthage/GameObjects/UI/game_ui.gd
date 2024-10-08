class_name GameUi extends Control

const _enums = preload("res://Singletons/enums.gd")
const start_menu : String = "res://Screens/StartScreen.tscn"
const game_screen : String = "res://Screens/GameScreen.tscn"
signal EndNight(dead_monkeys: Array[Monkey])

@onready var monkey_faces: MonkeyFaces = $MarginContainer/MonkeyFaces
@onready var monkey = preload("res://GameObjects/Animals/Monkey.tscn")
@onready var turn_counter = $MarginContainer/TurnCounter

@onready var leaf_counter = %leaf_food_counter
@onready var fruit_counter = %fruit_food_counter
@onready var grain_counter = %grain_food_counter
@onready var night_screen = $NightScreen
@onready var game_over_screen = $GameOverScreen
@onready var back_to_menu_betton = %BackToMenuButton
@onready var tutorial_label = %TutorialLabel
@onready var tutorial_screen = $TutorialScreen
@onready var tutorial_button = %TutorialTextureButton

@export var monkeys: Array[Monkey]

func _ready():
	night_screen.connect("EndNight", OnNightEnd)
	ColobsManager.connect("FoodPicked", UpdateFood)

func UpdateMonkeyFaces(monkeys: Array[Monkey]):
	monkey_faces.Update(monkeys)

func RemoveMonkeyFace(monkey : Monkey):
	monkey_faces.RemoveFace(monkey)

func UpdateTurnCounter(amount: int):
	turn_counter.UpdateTurn(amount)

func UpdatePeriod(period: _enums.PeriodType):
	turn_counter.ChangePeriod(period)

func UpdateFoodScreen():
	leaf_counter.UpdateCounter(round(ColobsManager._inventory.inventory.values()[_enums.PickableType.LEAF]))
	fruit_counter.UpdateCounter(round(ColobsManager._inventory.inventory.values()[_enums.PickableType.FRUIT]))
	grain_counter.UpdateCounter(round(ColobsManager._inventory.inventory.values()[_enums.PickableType.GRAIN]))

func UpdateFood(type: _enums.PickableType, amount: int):
	match type:
		_enums.PickableType.LEAF:
			leaf_counter.UpdateCounter(amount)
		_enums.PickableType.FRUIT:
			fruit_counter.UpdateCounter(amount)
		_enums.PickableType.GRAIN:
			grain_counter.UpdateCounter(amount)

func DisplayNightScreen():
	night_screen.show()
	night_screen.end_button.grab_focus()

func OnNightEnd(dead_monkeys):
	print("night signal captured")
	EndNight.emit(dead_monkeys)
	night_screen.hide()

func GameOverScreen():
	print("game over")
	$GameOverScreen/LoseSong.play()
	game_over_screen.show()
	back_to_menu_betton.grab_focus()
	get_tree().paused = true

func _on_back_to_menu_button_pressed():
	var tree = get_tree()
	tree.paused = false
	tree.change_scene_to_file(start_menu)

func TutorialScreen(text: String):
	if text == null || text == "":
		return
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	tutorial_screen.show()
	tutorial_button.grab_focus()
	tutorial_label.text = text


func _on_tutorial_texture_button_pressed():
	get_tree().paused = false
	tutorial_screen.hide()


func _on_home_button_pressed():
	get_tree().change_scene_to_file(start_menu)


func _on_reset_button_pressed():
	get_tree().change_scene_to_file(game_screen)
