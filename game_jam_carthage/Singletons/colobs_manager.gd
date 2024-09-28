extends Node

var _band : Array[Monkey] = []

func _ready():
	pass


func PushMonkeys(monkeys : Array[Monkey]):
	_band = monkeys
	
func PullMonkeys() -> Array[Monkey]:
	return _band
