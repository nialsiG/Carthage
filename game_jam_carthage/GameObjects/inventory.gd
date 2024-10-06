class_name Inventory
extends Node
const enums = preload("res://Singletons/enums.gd")

var inventory: Dictionary

func _initialize():
	for pickable_type in enums.PickableType:
		inventory[pickable_type] = 0

# picking is one by one
func _on_pickable_reveived(pickable: enums.PickableType):
	var pickableType = enums.PickableType.find_key(pickable)
	print("pickable: " + str(pickableType))
	inventory[str(pickableType)] = inventory[str(pickableType)] + 1
	print("inventory pickable = " + str(inventory[pickableType]))

# eating is at night, so monkeys eat a whole bunch
func _on_pickable_eaten(pickable: enums.PickableType, number_eaten: int):
	var pickableType = enums.PickableType.find_key(pickable)
	inventory[str(pickableType)] = inventory[str(pickableType)] - number_eaten
	print("inventory after night ", str(inventory))
