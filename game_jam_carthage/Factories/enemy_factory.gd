extends Node
class_name EnemyFactory

const enums = preload("res://Singletons/enums.gd")
var redPandaPS = preload("res://GameObjects/Animals/RedPanda.tscn")
var lynxPS = preload("res://GameObjects/Animals/Lynx.tscn")

var pandaMoveset1 = [Vector3(0, 0,1),Vector3(0,0,1), Vector3(0,0,1)]
var pandaMoveset2 = [Vector3(1,0,0),Vector3(1,0,0),Vector3(1,0,0)]
var pandaMoveset3 = [Vector3(-1,0,0),Vector3(-1,0,0),Vector3(-1,0,0)]
var pandaMoveset4 = [Vector3(0,0,-1),Vector3(0,0,-1),Vector3(0,0,-1)]

var lynxMoveset1 : Array[Vector3] = [Vector3(0, 0,1),Vector3(1,0,0), Vector3(0,0,1), Vector3(1,0,0)]
var lynxMoveset2 : Array[Vector3] = [Vector3(1,0,0),Vector3(0,0,1),Vector3(0,0,1),Vector3(0,0,1)]
var lynxMoveset3 : Array[Vector3] = [Vector3(-1,0,0),Vector3(0,0,-1),Vector3(-1,0,0),Vector3(0, 0,-1)]
var lynxMoveset4 : Array[Vector3] = [Vector3(0,0,-1),Vector3(-1,0,0),Vector3(0,0,-1), Vector3(-1,0,0)]

func GenerateEnemy(predatorType : enums.Enemies) -> Ennemy:
	if (predatorType == enums.Enemies.REDPANDA):
		var panda = redPandaPS.instantiate() as Ennemy
		var patternIndex = randi_range(0,3)
		match(patternIndex):
			0:
				panda._move_pattern.append_array(pandaMoveset1)
			1:
				panda._move_pattern.append_array(pandaMoveset2)
			2:
				panda._move_pattern.append_array(pandaMoveset3)
			3:
				panda._move_pattern.append_array(pandaMoveset4)
		return panda
	else:
		var lynx = lynxPS.instantiate() as Ennemy
		var patternIndex = randi_range(0,3)
		match(patternIndex):
			0:
				lynx._move_pattern.append_array(lynxMoveset1)
			1:
				lynx._move_pattern.append_array(lynxMoveset2)
			2:
				lynx._move_pattern.append_array(lynxMoveset3)
			3:
				lynx._move_pattern.append_array(lynxMoveset4)
		return lynx
