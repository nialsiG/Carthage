extends Node
class_name EnemyFactory

const enums = preload("res://Singletons/enums.gd")
var redPandaPS = preload("res://GameObjects/Animals/RedPanda.tscn")
var lynxPS = preload("res://GameObjects/Animals/Lynx.tscn")

func GenerateEnemy(predatorType : enums.Enemies) -> Ennemy:
	if (predatorType == enums.Enemies.REDPANDA):
		return redPandaPS.instantiate()
	else:
		return lynxPS.instantiate()
