extends Node
class_name ObstacleFactory

const enums = preload("res://Singletons/enums.gd")

var rockPS = preload("res://GameObjects/Obstacle/Rock.tscn")
var treePS = preload("res://GameObjects/Obstacle/Tree.tscn")

func CreateScene(pickableType : enums.ObstableType) -> Obstacle:
	if (pickableType == enums.ObstableType.TREE):
		return treePS.instantiate()
		
	return rockPS.instantiate()	
