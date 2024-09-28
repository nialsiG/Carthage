class_name Inventory
extends Node
const enums = preload("res://Singletons/enums.gd")

var inventory: Array[enums.PickableType]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# picking is one by one
func _on_pickable_reveived(pickable: enums.PickableType):
	inventory.append(pickable)

# eating is at night, so monkeys eat a whole Array
func _on_pickable_eaten(array_eaten: Array[enums.PickableType]):
	for eaten_counter in array_eaten.size():
		var eaten_pickable = array_eaten[eaten_counter]
		for inventory_counter in inventory.size():
			var item = inventory[inventory_counter]
			if item == eaten_pickable:
				inventory.pop_at(inventory_counter)
				break
	
