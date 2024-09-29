extends Node
class_name PickableFactory

const enums = preload("res://Singletons/enums.gd")

var fruitPS = preload("res://GameObjects/Pickables/PickableFruit.tscn")
var grainPS = preload("res://GameObjects/Pickables/PickableGrain.tscn")
var leafPS = preload("res://GameObjects/Pickables/PickableLeaf.tscn")

func CreateScene(pickableType : enums.PickableType) -> Pickable:
	if (pickableType == enums.PickableType.LEAF):
		return leafPS.instantiate()
	elif (pickableType == enums.PickableType.FRUIT):
		return fruitPS.instantiate()
	else:
		return grainPS.instantiate()
	
