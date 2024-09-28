class_name MonkeyFaces extends Control

const _enums = preload("res://Singletons/enums.gd")
const monkey_face = preload("res://GameObjects/UI/monkey_face.tscn")

func Update(array: Array[Monkey]):
	for monkey in array:
		AddFace(monkey)

func AddFace(monkey: Monkey):
	var new_monkey_face = monkey_face.instantiate()
	add_child(new_monkey_face)
	new_monkey_face.monkey = monkey
	# Diet:
	new_monkey_face.DisplayLeaf(monkey._diet.has(_enums.PickableType.LEAF))
	new_monkey_face.DisplayFruit(monkey._diet.has(_enums.PickableType.FRUIT))
	new_monkey_face.DisplayHerb(monkey._diet.has(_enums.PickableType.GRAIN))
