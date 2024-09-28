extends Node
class_name GameScreen

const enums = preload("res://Singletons/enums.gd")

@onready var elements : Node3D = $Elements
@onready var mousePositionLabel : Label =  $Label
@onready var _ground : Node3D = $Ground
@onready var _mapGenerator : MapGenerator = $MapGenerator

var _waitingForReactions : bool = false
var waitDurationBetweenActions : float = 0 # 0.3

#var _tiles : Array[TileMap] = []
var _map : Map
var monkeys :Array[Monkey] = []
var _strayMonkeys : Array[Monkey] = []
var leader : Monkey
var _focusTile : MapTile
var turn : int = 1
var hoveredTile : Vector3 = Vector3.ZERO
var _mapDimensions : Vector2 = Vector2(20, 20)

const InvalidMoveVector : Vector3 = Vector3(-10000, 0,-10000)

func _ready():
	_map = _mapGenerator.GenerateMap(self, _mapDimensions)
	add_child(_map)
	
	for pickable in _map.GetPickables():
		pickable.picked_consumable.connect(OnPickedConsumable)
	
	for element in elements.get_children():
		if (element is Monkey):
			var tile = _map.GetTilefromVec(Vector2(element.position.x, element.position.z))
			if (leader == null):
				element.SetLeader()
				
			element.SetTile(tile)
			if(element.IsLeader() && leader == null):
				leader = element
				leader.SetTile(_map.GetTilefromVec(ConvertPositionToTile(leader.position)))
						
			if (!element.IsStray()):
				monkeys.append(element)
				element.GrabLeaderShip.connect(OnGrabLeaderShip)
			else:
				_strayMonkeys.append(element)
				element.JoinedGroup.connect(OnMonkeyJoinGroup)
			
func _process(delta):
	if(_waitingForReactions):
		return
		
	CheckLeaderMove()

func OnGrabLeaderShip(monkey : Monkey):
	leader.StealLeadership()
	monkey.SetLeader()
	leader = monkey

func OnMonkeyJoinGroup(monkey : Monkey):
	var index = _strayMonkeys.find(monkey)
	monkey.GrabLeaderShip.connect(OnGrabLeaderShip)
	_strayMonkeys.remove_at(index)
	monkeys.append(monkey)	
	
func OnPickedConsumable(pickable_type : enums.PickableType):
	ColobsManager.PickItem(pickable_type)
	
func CheckLeaderMove() -> bool:
	var hasMoved = false
	var moveVector = Vector3.ZERO
	
	if(Input.is_action_just_pressed("Left")):
		moveVector = Vector3.LEFT
		
	if(Input.is_action_just_pressed("Right")):
		moveVector = Vector3.RIGHT
		
	if(Input.is_action_just_pressed("Top")):
		moveVector = Vector3.FORWARD
		
	if (Input.is_action_just_pressed("Down")):
		moveVector = Vector3.BACK

	if (moveVector == Vector3.ZERO):
		return false

	var tile = _map.GetTilefromVec(ConvertPositionToTile(leader.position + moveVector))
	if(tile == null):
		return false
	
	if(!TryGrabFocus(tile)):
		return false
	
	Move(leader, moveVector)
		
	return hasMoved

signal MousePosition(position : Vector2)

func TryGrabFocus(tile : MapTile)-> bool:
	var distance = (leader.GetTilePosition() - tile.GetTile()).length()
	var isValid = true 
	print(str(tile.GetTile())+" "+str(distance))
	if (distance != 1):
		isValid = false
	
	var obstructionType = tile.GetObstructionType()
	if (!leader.CanMoveThrough(obstructionType)):
		isValid = false
		
	#Check tile available for move (occupied or collision)
	if (_focusTile != null):
		_focusTile.ReleaseFocus()
	
	if (isValid):
		_focusTile = tile
	else:
		_focusTile = null
			
	return isValid
		
func _input(event):
	if (_focusTile == null || _waitingForReactions):
		return
		
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT):
		print("Right click")
		var positionDiff = _focusTile.GetTile() - leader.GetTilePosition()
		print("Diff position: "+str(positionDiff))
		if (positionDiff.length() <= 1):
			Move(leader, Vector3(positionDiff.x, 0, positionDiff.y))

func Move(target : MapItem, positionDiff : Vector3):
	target.position = target.position + positionDiff
	var tile = _map.GetTilefromVec(ConvertPositionToTile(target.position))
	var items = tile.GetMapItems()
	target.InteractWithItem(items)
	target.SetTile(tile)
	if _focusTile:
		_focusTile.ReleaseFocus()
	if (target  != leader):
		return
		$Night._on_new_turn(turn)
		
		
	_waitingForReactions = true
	
	for monkey in monkeys:
		await Wait(waitDurationBetweenActions)
		var move = monkey.React(leader, GetAvailableMoveTiles(monkey))
		if (move != null && move != Vector3.ZERO):
			Move(monkey, move)
		
	for monkey in _strayMonkeys:
		await Wait(waitDurationBetweenActions)
		var move = monkey.React(leader, GetAvailableMoveTiles(monkey))
		
	_waitingForReactions = false
		
	if (target  == leader):
		$Night._on_new_turn(turn)

func ConvertPositionToTile(tilePosition : Vector3) -> Vector2:
	var x = 0
	var z = 0

	x = snapped(tilePosition.x, 1)
	if (tilePosition.x < 0 && tilePosition.x + 0.5 > x + 1):
		x += -1
	elif (tilePosition.x > 0 && tilePosition.x < x - 0.5):
		x += 1
		
	z = snapped(tilePosition.z, 1)	
	if (tilePosition.z < 0 && tilePosition.z + 0.5 > z + 1):
		z += -1
	elif (tilePosition.z > 0 && tilePosition.z < z - 0.5):
		z += 1
		
	return Vector2(x,z)

func Wait(duration : float):
	await get_tree().create_timer(duration).timeout

func GetAvailableMoveTiles(monkey : Monkey) -> Array[MapTile]:
	var tiles : Array[MapTile] = []
	for pattern in monkey._patterns:
		var directPosition = monkey.GetTilePosition() + pattern
		if (IsInMap(directPosition)):
			tiles.append(_map.GetTilefromVec(directPosition))
		var opposite = monkey.GetTilePosition() - pattern
		if (IsInMap(opposite)):
			tiles.append(_map.GetTilefromVec(opposite))
			
	return tiles

func IsInMap(position : Vector2) -> bool:
	if (position.x < - _mapDimensions.x /2 + 1 && position.x > _mapDimensions.x / 2):
		return false
	if (position.y < - _mapDimensions.y /2 + 1 && position.y > _mapDimensions.y / 2):
		return false
		
	return true
