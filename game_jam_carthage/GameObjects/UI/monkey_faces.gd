class_name MonkeyFaces extends Control

const _enums = preload("res://Singletons/enums.gd")
const monkey_face = preload("res://GameObjects/UI/monkey_face.tscn")

@onready var face_container = $HBoxContainer

func Update(array: Array[Monkey]):
	if face_container.get_child_count() > 0:
		var children = face_container.get_children()
		for c in children:
			face_container.remove_child(c)
			c.queue_free()
	for monkey in array:
		AddFace(monkey)

func AddFace(monkey: Monkey):
	var new_monkey_face = monkey_face.instantiate()
	face_container.add_child(new_monkey_face)
	new_monkey_face.monkey = monkey
	new_monkey_face.update_asset(monkey._asset)
	# Diet:
	new_monkey_face.DisplayLeaf(monkey._diet.has(_enums.PickableType.LEAF))
	new_monkey_face.DisplayFruit(monkey._diet.has(_enums.PickableType.FRUIT))
	new_monkey_face.DisplayHerb(monkey._diet.has(_enums.PickableType.GRAIN))
