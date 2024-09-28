extends CharacterBody3D
class_name Monkey

@onready var _cellLeft : CSGBox3D =  $CellLeft
@onready var _cellRight : CSGBox3D =  $CellRight
@onready var _cellTop : CSGBox3D =  $CellTop
@onready var _cellBottom : CSGBox3D =  $CellBottom

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
	HideAllCells()
		
func NotifyTurnEnd():
	_waitingForTurnCompletion = false

func React():
	if (_isLeader || _isStray):
		return

func LightUp(mousePosition : Vector2):
	HideAllCells()
	
	var diff = Vector2(position.x, position.z) - mousePosition
	if (0.5 < diff.x && diff.x <= 1.5 && abs(diff.y) < 0.5 ):
		_cellLeft.show()
		
	elif (-0.5 > diff.x && diff.x >= -1.5 && abs(diff.y) < 0.5 ):
		_cellRight.show()
	
	elif (0.5 < diff.y && diff.y <= 1.5 && abs(diff.x) < 0.5 ):
		_cellTop.show()
		
	elif (-0.5 > diff.y && diff.y >= -1.5 && abs(diff.x) < 0.5 ):
		_cellBottom.show()


func _on_input_event(camera, event, event_position, normal, shape_idx):
	HideAllCells()

func HideAllCells():
	_cellLeft.hide()
	_cellRight.hide()
	_cellTop.hide()
	_cellBottom.hide()
