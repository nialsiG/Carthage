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
	_isLeader = true
		
func NotifyTurnEnd():
	_waitingForTurnCompletion = false

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
			if (distance <= currentDistanceToLeader):
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
