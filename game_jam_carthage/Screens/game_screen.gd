extends Node
class_name GameScreen

const enums = preload("res://Singletons/enums.gd")

@onready var elements : Node3D = $Elements
@onready var mousePositionLabel : Label =  $Label
@onready var _ground : Node3D = $Ground
@onready var _mapGenerator : MapGenerator = $MapGenerator
@onready var _gameUi: GameUi = $CanvasLayer/GameUi
@onready var _nightscreen = $Night

var _waitingForReactions : bool = false
var waitDurationBetweenActions : float = 0 # 0.3

#var _tiles : Array[TileMap] = []
var _map : Map
var monkeys : Array[Monkey] = []
var _strayMonkeys : Array[Monkey] = []
var leader : Monkey
var _focusTile : MapTile
var turn : int = 1
var hoveredTile : Vector3 = Vector3.ZERO
var _mapDimensions : Vector2 = Vector2(20, 20)

const InvalidMoveVector : Vector3 = Vector3(-10000, 0,-10000)

var arrived_from: enums.PositionOnMap = enums.PositionOnMap.RIGHT
var current_position_on_map: enums.PositionOnMap
var leader_start_position: Vector3 

func _ready():
	makeNewMap()
	
	for element in elements.get_children():
		if (element is Monkey):
			var tile = _map.GetTilefromVec(Vector2(element.position.x, element.position.z))
			if (leader == null):
				element.SetLeader()
				
			element.SetTile(tile)
			if(element.IsLeader() && leader == null):
				leader = element
				leader.position = leader_start_position
				leader.SetTile(_map.GetTilefromVec(ConvertPositionToTile(leader.position)))
						
			if (!element.IsStray()):
				element.GrabLeaderShip.connect(OnGrabLeaderShip)
				monkeys.append(element)
			else:
				_strayMonkeys.append(element)
				element.JoinedGroup.connect(OnMonkeyJoinGroup)


	if (leader == null):
		leader = monkeys[0]
		leader.SetLeader()

	# Initial update UI
	_gameUi.UpdateMonkeyFaces(monkeys)
	_gameUi.UpdateTurnCounter(turn)
	_gameUi.UpdatePeriod(enums.PeriodType.TORTONIAN)
	_gameUi.connect("EndNight", OnNightEnd)
	_nightscreen.connect("night_time", OnNightStart)


			
func _process(delta):
	if(_waitingForReactions):
		return
		
	CheckLeaderMove()

func OnGrabLeaderShip(monkey : Monkey):
	leader.StealLeadership()
	var isOldLeaderStillLeader = leader.IsLeader()
	monkey.SetLeader()
	leader = monkey
	_gameUi.UpdateMonkeyFaces(monkeys)

func OnMonkeyJoinGroup(monkey : Monkey):
	var index = _strayMonkeys.find(monkey)
	monkey.GrabLeaderShip.connect(OnGrabLeaderShip)
	_strayMonkeys.remove_at(index)
	monkeys.append(monkey)
	_gameUi.UpdateMonkeyFaces(monkeys)
	
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
	if tile:
		var items = tile.GetMapItems()
		target.InteractWithItem(items)
		target.SetTile(tile)
	if _focusTile:
		_focusTile.ReleaseFocus()
		
	if (target  == leader):
		var border_detection: enums.PositionOnMap = detectBorders(target.GetTilePosition())
		if border_detection != enums.PositionOnMap.MIDDLE:
			if border_detection == arrived_from:
				# cannot leave from where we're from
				pass
			else:
				arrived_from = border_detection
				_map.queue_free()
				makeNewMap()
				_set_leader_position()
				for monkey in monkeys:
					var newMonkeyTile = _map.GetTilefromVec(Vector2(monkey.position.x, monkey.position.z))
					monkey.SetTile(newMonkeyTile)
					
				for monkey in _strayMonkeys:
					monkey.queue_free()
				_strayMonkeys.clear()
					
				return
		turn += 1
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

func detectBorders(leader_position: Vector2) -> enums.PositionOnMap:
	if leader_position[0] == -round(_mapDimensions[0]/2) + 1:
		return enums.PositionOnMap.DOWN
	elif leader_position[0] == round(_mapDimensions[0]/2):
		return enums.PositionOnMap.UP
	elif leader_position[1] == round(_mapDimensions[1]/2):
		return enums.PositionOnMap.RIGHT
	elif leader_position[1] == -round(_mapDimensions[1]/2) + 1:
		return enums.PositionOnMap.LEFT
	else:
		return enums.PositionOnMap.MIDDLE

func makeNewMap():		
	for monkey in monkeys:
		monkey._tile = null
		
	_map = _mapGenerator.GenerateMap(self, _mapDimensions)
	add_child(_map)
	
	for pickable in _map.GetPickables():
		pickable.picked_consumable.connect(OnPickedConsumable)
				
	
func _set_leader_position():
	match arrived_from:
		enums.PositionOnMap.UP:
			leader.position =  Vector3(-round(_mapDimensions[0]/2) + 1, 0, 0)
		enums.PositionOnMap.DOWN:
			leader.position = Vector3(round(_mapDimensions[0]/2), 0, 0)
		enums.PositionOnMap.LEFT:
			leader.position = Vector3(0, 0, round(_mapDimensions[1]/2))
		enums.PositionOnMap.RIGHT:
			leader.position = Vector3(0, 0, round(_mapDimensions[1]/2))
		_:
			leader.position = Vector3(0, 0, 0)
		
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

func OnNightStart():
	# monkey hunger
	# pinpoint dead monkey(s)
	_gameUi.DisplayNightScreen()

func OnNightEnd():
	# remove
	pass
