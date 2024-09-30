extends MapItem
class_name Ennemy

const _enums = preload("res://Singletons/enums.gd") 
var _waitingForTurnCompletion : bool

var _move_pattern: Array[Vector3] = []

var satiation_time: int = 4
var satiated: int

func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	if _move_pattern.size() == 0:
		_move_pattern = [Vector3(0, 0, 1),Vector3(0, 0, 1), Vector3(0, 0, 1)]
		
func NotifyTurnEnd():
	_waitingForTurnCompletion = false
	
func Movement(turn: int):
	if satiated == 0 or satiated == 4:
		# move here
		var full_pattern: int = _move_pattern.size() * 2
		if turn % full_pattern < _move_pattern.size():
			return _move_pattern[turn % _move_pattern.size()]
		else:
			return -1 * _move_pattern[turn % _move_pattern.size()]
	# eaten, don't move
	else:
		satiated -= 1
		return

func InteractWithItem(mapItems : Array[MapItem]):
	for item in mapItems:
		if (item is Monkey):
			# monkey Death here
			if (_tile != null):
				_tile.LeaveTile(self)
			item.Eaten()
			$EatMonkeySound.play()
			
	satiated = satiation_time
	
func _flip_h(move_vector):
	if move_vector[0] < 0:
		$ViewPortQuad.flip_h = false
	if move_vector[0] > 0:
		$ViewPortQuad.flip_h = true
	
