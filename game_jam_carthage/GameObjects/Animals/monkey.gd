extends MapItem
class_name Monkey

var _isLeader : bool = false
var _isStray : bool = true
var _waitingForTurnCompletion : bool

var _patterns : Array[Vector2] = [Vector2(0,1), Vector2(1,0)]

@onready var _diet: Array[enums.PickableType]
@onready var _move_pattern: Array[int] = [2, 1]
@onready var _locomotion: enums.LocomotionType = enums.LocomotionType.ARBOREAL

signal JoinedGroup(monkey : Monkey)
signal GrabLeaderShip(monkey : Monkey)

func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	_diet.append(enums.PickableType.LEAF)

func IsLeader():
	return _isLeader

func IsStray():
	return _isStray

func JoinGroup():
	_isStray = false
	JoinedGroup.emit(self)

func SetLeader():
	_isLeader = true
	_isStray = false
	
func StealLeadership():
	_isLeader = false
		
func NotifyTurnEnd():
	_waitingForTurnCompletion = false

func CanMoveThrough(obstacleType : enums.ObstableType):
	match(obstacleType):
		enums.ObstableType.NONE:
			return true
		enums.ObstableType.ROCK:
			return false
		enums.ObstableType.TREE:
			return _locomotion == enums.LocomotionType.ARBOREAL
		enums.ObstableType.ROCK:
			return true
		enums.ObstableType.MONKEY:
			return false
		enums.ObstableType.PREDATOR:
			return false
			
func React(leader : Monkey, tiles : Array[MapTile]):
	if (_isLeader):
		return

	if (_isStray):
		CheckMonkeyClose(tiles)
	else:
		var closestTile = _tile
		var currentDistanceToLeader = (leader.GetTilePosition() - _tile.GetTile()).length()
		for tile in tiles:
			var distance = (leader.GetTilePosition() - tile.GetTile()).length()
			if (distance <= currentDistanceToLeader && distance > 0):
				closestTile = tile
				currentDistanceToLeader = distance
	
		if (closestTile != _tile):
			var moveVector = (closestTile.GetTile() - _tile.GetTile())
			return Vector3(moveVector.x, 0, moveVector.y)
			#SetTile(closestTile)

func CheckMonkeyClose(tiles : Array[MapTile]):
	for tile in tiles:
			var items = tile.GetMapItems()
			for item in items:
				if (item is Monkey):
					JoinGroup()
					return

func InteractWithItem(mapItems : Array[MapItem]):
	for item in mapItems:
		if (item is Pickable):
			item._on_got_picked()

func _on_monkey_input_event(camera, event, event_position, normal, shape_idx):
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		GrabLeaderShip.emit(self)
