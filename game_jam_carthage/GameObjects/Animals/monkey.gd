extends MapItem
class_name Monkey

var _isLeader : bool = true
var _isStray : bool = true
var _waitingForTurnCompletion : bool

func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE

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

func React():
	if (_isLeader || _isStray):
		return
