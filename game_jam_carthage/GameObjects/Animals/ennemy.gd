extends MapItem
class_name Ennemy

const _enums = preload("res://Singletons/enums.gd") 
var _waitingForTurnCompletion : bool

var _move_pattern: Array[Vector3] = []
var _lookLeft : bool = false
var satiation_time: int = 4
var satiated: int = 0
var _moveCounter = 0

func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	if _move_pattern.size() == 0:
		_move_pattern = [Vector3(0, 0, 1),Vector3(0, 0, 1), Vector3(0, 0, 1)]
		
func NotifyTurnEnd():
	_waitingForTurnCompletion = false
	
func GetMovement() -> Vector3:	
	if satiated == 0:
		# move here
		var full_pattern: int = _move_pattern.size() * 2
		var newMove = Vector3.ZERO
		if _moveCounter % full_pattern < _move_pattern.size():
			newMove = _move_pattern[_moveCounter % _move_pattern.size()]
		else:
			newMove = -1 * _move_pattern[_moveCounter % _move_pattern.size()]
		_moveCounter+=1
		return newMove
	else:
		satiated -= 1
		if (satiated == 0):
			UpdateDangerZone()
		return Vector3.ZERO

func InteractWithItem(mapItems : Array[MapItem]):
	if (satiated):
		return
		
	for item in mapItems:
		if (item is Monkey):
			# monkey Death here
			if (_tile != null):
				_tile.LeaveTile(self)
			item.Eaten()
			$EatMonkeySound.play()
			satiated = satiation_time
			UpdateDangerZone()

func InteractWithSideItem(mapItems : Array, isLeft : bool):
	if (isLeft && !ControlLeft()):
		return
	if (!isLeft && !ControlRight()):
		return 
	InteractWithItem(mapItems)

func ControlLeft() -> bool:
	return true

func ControlRight() -> bool:
	return true

func UpdateDangerZone():
	if (satiated > 0):
		$DangerZoneRight.hide()
		$DangerZoneMiddle.hide()
		$DangerZoneLeft.hide()
	else:
		$DangerZoneRight.show()
		$DangerZoneMiddle.show()
		$DangerZoneLeft.show()

func _flip_h(move_vector):
	if move_vector[0] < 0:
		_lookLeft = true
		$ViewPortQuad.flip_h = true
	if move_vector[0] > 0:
		_lookLeft = false
		$ViewPortQuad.flip_h = false
	
