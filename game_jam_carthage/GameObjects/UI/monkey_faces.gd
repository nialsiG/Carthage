class_name MonkeyFaces extends Control

func Update(array: Array[Monkey]):
	for monkey in array:
		AddFace(monkey)

func AddFace(Monkey):
	var newMonkeyFace: MonkeyFace
	# Diet:
	if true:
		newMonkeyFace.DisplayLeaf()
		newMonkeyFace.DisplayFruit()
		newMonkeyFace.DisplayHerb()
