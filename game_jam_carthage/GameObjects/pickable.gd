extends MapItem
class_name Pickable

const enums = preload("res://Singletons/enums.gd")

signal picked_consumable(pickable: enums.PickableType)

@export var pickable_type: enums.PickableType = enums.PickableType.LEAF

func _on_got_picked():
	picked_consumable.emit(pickable_type)
