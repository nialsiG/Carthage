extends MapItem
class_name Pickable

signal picked_consumable(pickable: enums.PickableType)

@export var pickable_type: enums.PickableType = enums.PickableType.LEAF

func _on_got_picked():
	picked_consumable.emit(pickable_type)
	if (_tile != null):
		_tile.LeaveTile(self)
	queue_free()
