class_name MonkeyFaces extends Control


func Update(faceArray):
	for face in faceArray:
		AddFace(face.sprite, face.diet)

func AddFace(sprite, diet):
	pass
