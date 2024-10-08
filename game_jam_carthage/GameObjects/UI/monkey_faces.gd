class_name MonkeyFaces extends Control

const _enums = preload("res://Singletons/enums.gd")
const monkey_face = preload("res://GameObjects/UI/monkey_face.tscn")

var face_container : HBoxContainer
func _ready():
	face_container = get_node("HBoxContainer")
	pass

func Update(array: Array[Monkey]):
	if face_container.get_child_count() > 0:
		var children = face_container.get_children()
		for c in children:
			face_container.remove_child(c)
			c.queue_free()
	for monkey in array:
		AddFace(monkey)

func RemoveFace(monkey : Monkey):
	for child in face_container.get_children():
		if (child.monkey == monkey):
			child.queue_free()
			return


func AddFace(monkey: Monkey):
	var new_monkey_face = monkey_face.instantiate()
	face_container.add_child(new_monkey_face)
	new_monkey_face.SetMonkey(monkey)
