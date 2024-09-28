extends Node
class_name MonkeyGenerator

const enums = preload("res://Singletons/enums.gd")
const monkeysPS = preload("res://GameObjects/Animals/Monkey.tscn")

func _ready():
	randomize()

func GenerateMonkey(can_eat_n_things: int = 1, 
					locomotion_type: enums.LocomotionType = enums.LocomotionType.TERRESTRIAL):
	var monkey = monkeysPS.instantiate() as Monkey
	# set things that it can eat
	while monkey._diet.size() < can_eat_n_things:
		var random_food = randi_range(0, enums.PickableType.size() - 1)
		if random_food not in monkey._diet:
			monkey._diet.append(random_food)
	# set locomotion type
	monkey._locomotion = locomotion_type
	
	return monkey
	
