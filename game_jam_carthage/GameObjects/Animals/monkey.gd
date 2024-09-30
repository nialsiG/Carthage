extends MapItem
class_name Monkey

var _isLeader : bool = false
var _isStray : bool = true
var _waitingForTurnCompletion : bool
var _patterns : Array[Vector2] = [Vector2(0,1), Vector2(1,0)]
var _asset : int = randi_range(0, 2)

var Name : String = ""

@onready var _diet: Array[enums.PickableType]
@onready var _move_pattern: Array[int] = [2, 1]
var _locomotion: enums.LocomotionType

signal JoinedGroup(monkey : Monkey)
signal GrabLeaderShip(monkey : Monkey)
signal GotEaten(monkey: Monkey)

func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	
	var texture_array = [$SubViewport/monkey1, $SubViewport/monkey2, $SubViewport/monkey3]
	for texture in texture_array:
		texture.visible = false
	texture_array[_asset].visible = true

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
			if(!leader.CanMoveThrough(tile.GetObstructionType())):
				continue
			var distance = (leader.GetTilePosition() - tile.GetTile()).length()
			if (distance <= currentDistanceToLeader && distance > 0):
				closestTile = tile
				currentDistanceToLeader = distance
	
		if (closestTile != _tile):
			var moveVector = (closestTile.GetTile() - _tile.GetTile())
			return Vector3(moveVector.x, 0, moveVector.y)
		else:
			$FoundOrBlockedSound.play()

func CheckMonkeyClose(tiles : Array[MapTile]):
	for tile in tiles:
		var items = tile.GetMapItems()
		for item in items:
			if (item is Monkey):
				$FoundOrBlockedSound.play()
				JoinGroup()
				return

func InteractWithItem(mapItems : Array[MapItem]):
	for item in mapItems:
		if (item is Pickable):
			item._on_got_picked()
			$EatSound.play()

func _on_monkey_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if (_isStray):
		return
		
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):		
		GrabLeaderShip.emit(self)
			
func Eaten():
	GotEaten.emit(self)
	queue_free()
	
func _flip_h(move_vector):
	if move_vector[0] > 0:
		$ViewPortQuad.flip_h = false
	elif move_vector[0] < 0:
		$ViewPortQuad.flip_h = true
