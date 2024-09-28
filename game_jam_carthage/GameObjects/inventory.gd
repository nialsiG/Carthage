class_name Inventory
extends Node
const enums = preload("res://Singletons/enums.gd")

var inventory: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pickable_type in enums.PickableType:
		inventory[pickable_type] = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# picking is one by one
func _on_pickable_reveived(pickable: enums.PickableType):
	var pickableType = enums.PickableType.find_key(pickable)
	inventory[pickable] = inventory[pickableType] + 1

# eating is at night, so monkeys eat a whole bunch
func _on_pickable_eaten(pickable: enums.PickableType, number_eaten: int):
	inventory[pickable] = inventory[pickable] - number_eaten
				
	
