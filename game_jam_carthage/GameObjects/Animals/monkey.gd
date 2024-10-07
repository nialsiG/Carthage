extends MapItem
class_name Monkey

var _isLeader : bool = false
var _leaderColor : Color = Color("#de8d5bc1")
var _isStray : bool = true
var _strayColor : Color = Color("#dededec1")
var _waitingForTurnCompletion : bool
var _patterns : Array[Vector2] = [Vector2(0,1), Vector2(1,0)]
var _asset : int = randi_range(0, 2)

var monkey1 = preload("res://Assets/Sprites/monkey/Monkey1_animation.tres")
var monkey2 = preload("res://Assets/Sprites/monkey/Monkey3_animation.tres")
var monkey3 = preload("res://Assets/Sprites/monkey/Monkey2_animation.tres")

var Name : String = ""

@onready var _diet: Array[enums.PickableType]
@onready var _move_pattern: Array[int] = [2, 1]
var _locomotion: enums.LocomotionType

signal JoinedGroup(monkey : Monkey)
signal GrabLeaderShip(monkey : Monkey)
signal GotEaten(monkey: Monkey)

func _ready():
	match(_asset):
		0:
			$AnimatedSprite3D.material_override.set_shader_parameter("sprite_texture", monkey1)
		1:
			$AnimatedSprite3D.material_override.set_shader_parameter("sprite_texture", monkey2)
		2:
			$AnimatedSprite3D.material_override.set_shader_parameter("sprite_texture", monkey3)
	$AnimatedSprite3D.play()
	
func IsLeader():
	return _isLeader

func IsStray():
	return _isStray

func JoinGroup():
	_isStray = false
	JoinedGroup.emit(self)

func SetLeader():
	$AnimatedSprite3D.material_override.set_shader_parameter("color", _leaderColor)
	$AnimatedSprite3D.material_override.set_shader_parameter("enabled", true)
	_isLeader = true
	_isStray = false
	
func StealLeadership():
	$AnimatedSprite3D.material_override.set_shader_parameter("color", _strayColor)
	$AnimatedSprite3D.material_override.set_shader_parameter("enabled", false)
	_isLeader = false
		
func NotifyTurnEnd():
	_waitingForTurnCompletion = false

func CanMoveThrough(obstacleType : enums.ObstableType, asLeader : bool):
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
			return asLeader
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
			if(!leader.CanMoveThrough(tile.GetObstructionType(), false)):
				continue
			var distance = (leader.GetTilePosition() - tile.GetTile()).length()			
			if ((distance <= currentDistanceToLeader && distance > 0) || currentDistanceToLeader == 0):
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
				if (!item.IsStray()):
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
	_isMoving = false
	queue_free()
	
func _flip_h(move_vector):
	if move_vector[0] > 0:
		$AnimatedSprite3D.flip_h = false
	elif move_vector[0] < 0:
		$AnimatedSprite3D.flip_h = true


func _on_static_body_3d_mouse_entered() -> void:
	if not _isStray and not _isLeader:
		$AnimatedSprite3D.material_override.set_shader_parameter("enabled", true)

func _on_static_body_3d_mouse_exited() -> void:
	if not _isStray and not _isLeader:
		$AnimatedSprite3D.material_override.set_shader_parameter("enabled", false)
