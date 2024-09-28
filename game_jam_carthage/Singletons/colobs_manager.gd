extends Node
class_name BandManager

var _band : Array[Monkey] = []
const enums = preload("res://Singletons/enums.gd")
@onready var _inventory: Inventory = $Inventory

func _ready():
	pass

func PushMonkeys(monkeys : Array[Monkey]):
	_band = monkeys
	
func PullMonkeys() -> Array[Monkey]:
	return _band

func PickItem(pickable : enums.PickableType):
	_inventory._on_pickable_reveived(pickable)

func MonkeyDied(monkey : Monkey):
	pass
	
func LeftScene():
	pass
	
