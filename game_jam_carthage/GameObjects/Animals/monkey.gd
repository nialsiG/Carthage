extends MapItem
class_name Monkey

const _enums = preload("res://Singletons/enums.gd") 
var _isLeader : bool = true
var _isStray : bool = true
var _waitingForTurnCompletion : bool

@onready var _diet: Array[_enums.PickableType]
@onready var _move_pattern: Array[int] = [2, 1]
@onready var _locomotion: _enums.LocomotionType = _enums.LocomotionType.ARBOREAL

func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	_diet.append(_enums.PickableType.LEAF)

func IsLeader():
	return _isLeader

func IsStray():
	return _isStray

func JoinGroup():
	_isStray = false

func SetLeader():
	_isLeader = true
	
func StealLeadership():
	_isLeader = true
		
func NotifyTurnEnd():
	_waitingForTurnCompletion = false

func React(tiles : Array[MapTile]):
	if (_isLeader):
		return

	if (_isStray):
		pass #check leader is close

func InteractWithItem(mapItems : Array[MapItem]):
	for item in mapItems:
		if (item is Pickable):
			item._on_got_picked()
