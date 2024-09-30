extends Node
class_name MonkeyGenerator

const enums = preload("res://Singletons/enums.gd")
const monkeysPS = preload("res://GameObjects/Animals/Monkey.tscn")

const _nameArray : Array[String] = ["Pfft", "Fft", "Pfrt", "Frt", "Coo", "Cwoo", "Cawoo", "Cowoo", "Iii", "Iik", "Wii", "Wiik", "Ikik", "Wikik", "Rrr", "Prr", "Houn", "Houm", "Pok", "Pok", "K'", "Wahou", "Waou", "Woo"]

func _ready():
	randomize()

func GenerateMonkeyName() -> String:
	var Name = _nameArray.pick_random()
	for i in 1:
		Name += "-"+_nameArray.pick_random()
	return Name

func GenerateMonkey(can_eat_n_things: int = 1) -> Monkey:
	var monkey = monkeysPS.instantiate() as Monkey
	monkey.Name = GenerateMonkeyName()
	var eatLeaves : bool = false
	while monkey._diet.size() < can_eat_n_things:
		var random_food = randi_range(0, enums.PickableType.size() - 1)
		if random_food == enums.PickableType.LEAF:
			eatLeaves = true
		if random_food not in monkey._diet:
			monkey._diet.append(random_food)
	if (eatLeaves):
		monkey._locomotion = enums.LocomotionType.ARBOREAL
	else:
		monkey._locomotion = enums.LocomotionType.TERRESTRIAL
	# choose asset
	monkey._asset = randi_range(0, 2)
	return monkey
	
func GenerateStarterMonkey() -> Monkey:
	var monkey = monkeysPS.instantiate() as Monkey
	monkey.Name = GenerateMonkeyName()
	monkey._diet.append(enums.PickableType.LEAF)
	monkey._locomotion = enums.LocomotionType.ARBOREAL
	return monkey
