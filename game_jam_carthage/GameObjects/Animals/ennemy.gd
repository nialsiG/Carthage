extends MapItem
class_name Ennemy

const _enums = preload("res://Singletons/enums.gd") 
var _waitingForTurnCompletion : bool

@onready var _move_pattern: Array[int] = [2, 1]

func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	
		
func NotifyTurnEnd():
	_waitingForTurnCompletion = false
	
func Movement():
	pass

func EatMonkey(mapItems : Array[MapItem]):
	for item in mapItems:
		if (item is Monkey):
			# monkey Death here
			if (_tile != null):
				_tile.LeaveTile(self)
			item.Eaten()
