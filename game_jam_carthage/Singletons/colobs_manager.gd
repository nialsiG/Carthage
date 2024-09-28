extends Node
class_name BandManager

var _band : Array[Monkey] = []

func _ready():
	pass

func PushMonkeys(monkeys : Array[Monkey]):
	_band = monkeys
	
func PullMonkeys() -> Array[Monkey]:
	return _band

func PickItem(pickable : Pickable):
	pass

func MonkeyDied(monkey : Monkey):
	pass
	
func LeftScene():
	pass
	
