extends Node
class_name GameScreen

const enums = preload("res://Singletons/enums.gd")

signal new_turn

@onready var elements : Node3D = $Elements
@onready var mousePositionLabel : Label =  $Label
@onready var _ground : Node3D = $Ground
@onready var _mapGenerator : MapGenerator = $MapGenerator
@onready var _gameUi: GameUi = $CanvasLayer/GameUi
@onready var _nightscreen = $Night

@onready var _startScreenScene =  "res://Screens/StartScreen.tscn"

var _waitingForReactions : bool = false
var waitDurationBetweenActions : float = 0.1
var _entryPoint : Vector3 = Vector3.ZERO

var _map : Map
var monkeys : Array[Monkey] = []
var _ennemies : Array[Ennemy] = []
var _strayMonkeys : Array[Monkey] = []
var _monkeysWaitingForEntry : Array[Monkey] = []
var leader : Monkey
var _focusTile : MapTile
var turn : int = 1
var hoveredTile : Vector3 = Vector3.ZERO
var _mapDimensions : Vector2 = Vector2(20, 20)

const InvalidMoveVector : Vector3 = Vector3(-10000, 0,-10000)

var arrived_from: enums.PositionOnMap = enums.PositionOnMap.MIDDLE
var current_position_on_map: enums.PositionOnMap
var leader_start_position: Vector3 

func _ready():
	ColobsManager.InitializeGame()
	monkeys = ColobsManager.PullMonkeys()
	makeNewMap()
	
	for monkey in monkeys:
		if monkey.IsLeader():
			leader = monkey
		elements.add_child(monkey)
		monkey.GotEaten.connect(OnMonkeyEaten)
	leader.SetTile(_map.GetTilefromVec(ConvertPositionToTile(leader.position)))
		
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
	monkey.reparent(elements)
	_strayMonkeys.remove_at(index)
	monkeys.append(monkey)
	_gameUi.UpdateMonkeyFaces(monkeys)
	
func OnMonkeyEaten(monkey : Monkey):
	monkey.GetTile().LeaveTile(monkey)
	
	var indexMonkey = monkeys.find(monkey)
	if (indexMonkey >= 0):
		monkeys.erase(monkey)
		if (monkey.IsLeader()):
			leader = null
			monkey.StealLeadership()
	else:
		indexMonkey = _strayMonkeys.find(monkey)
		if (indexMonkey >= 0):
			_strayMonkeys.erase(monkey)
		
	print("monkey eaten, remaining ", monkeys.size())
	if monkeys.size() == 0:
		_waitingForReactions = true
		print("LOOSE, all monkeys eaten")
		ColobsManager.MonkeyDied(monkey, enums.DeathCause.BEAST)
		await Wait(2.0)
		_gameUi.GameOverScreen()
		
	if (leader == null) and monkeys.size() > 0:
		print("changing leader pour cause de mort")
		leader = monkeys[0]
		leader.SetLeader()
	
func OnPickedConsumable(pickable_type : enums.PickableType):
	ColobsManager.PickItem(pickable_type)
	
func CheckLeaderMove() -> bool:
	if leader == null:
		return false
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
	if leader == null:
		return false
	var distance = (leader.GetTilePosition() - tile.GetTile()).length()
	var isValid = true
	print(str(tile.GetTile())+" "+str(distance))
	if (distance != 1):
		isValid = false
	
	var obstructionType = tile.GetObstructionType()
	if (!leader.CanMoveThrough(obstructionType)):
		isValid = false
		
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
		var positionDiff = _focusTile.GetTile() - leader.GetTilePosition()
		if (positionDiff.length() <= 1):
			Move(leader, Vector3(positionDiff.x, 0, positionDiff.y))

func Move(target : MapItem, positionDiff : Vector3):
	$MonkeyMove.play()
	target.position = target.position + positionDiff
	target._flip_h(positionDiff)
	var tile = _map.GetTilefromVec(ConvertPositionToTile(target.position))
	if tile:
		var items = tile.GetMapItems()
		target.InteractWithItem(items)
		target.SetTile(tile)
	if _focusTile:
		_focusTile.ReleaseFocus()
		
	if (target  == leader):
		IncrementTurn()
		var border_detection: enums.PositionOnMap = detectBorders(target.GetTilePosition())
		if border_detection != enums.PositionOnMap.MIDDLE:
			if border_detection == GetOppositeOfBorder(arrived_from):
				# cannot leave from where we're from
				pass
			else:
				arrived_from = border_detection
				_map.queue_free()
				if(!ColobsManager.LeftScene(arrived_from)):
					return
				makeNewMap()
				_set_leader_position()
				leader.SetTile(_map.GetTile(_entryPoint.x, _entryPoint.z))
				for monkey in monkeys:
					if (!monkey.IsLeader()):
						monkey.hide()
						_monkeysWaitingForEntry.append(monkey)
				
				ColobsManager.PushMonkeys(monkeys)				
				monkeys.clear()
				monkeys.append(leader)	
		
				return

	if (target  != leader):
		return

	_waitingForReactions = true
	
	for monkey in monkeys:
		if monkey != leader:
			await Wait(waitDurationBetweenActions)
			var move = monkey.React(leader, GetAvailableMoveTiles(monkey))
			if (move != null && move != Vector3.ZERO):
				Move(monkey, move)
	
	if(_monkeysWaitingForEntry.size() > 0):
		var monkey = _monkeysWaitingForEntry[0]
		monkey.position = _entryPoint
		monkey.reparent(elements)
		monkey.SetTile(_map.GetTilefromVec(Vector2(_entryPoint.x, _entryPoint.z)))
		monkeys.append(monkey)
		monkey.show()
		_monkeysWaitingForEntry.remove_at(0)
		
	for monkey in _strayMonkeys:
		var move = monkey.React(leader, GetAvailableMoveTiles(monkey))
		
	for ennemy in _ennemies:
		await Wait(waitDurationBetweenActions)
		var move = ennemy.Movement(turn)
		if move:
			Move(ennemy, move)
		
	_waitingForReactions = false

func IncrementTurn():
	turn += 1
	_gameUi.UpdateTurnCounter(turn)
	$Night._on_new_turn(turn)
	
func _on_night(dead_monkeys: Array[int], dead_monkeys_reason: Array[enums.PickableType]):
	# TODO: send infos to night screen here !!!
	for index in dead_monkeys:
		monkeys[index].GetTile().LeaveTile(monkeys[index])
		monkeys[index].queue_free()
		monkeys.remove_at(index)

func GetOppositeOfBorder(position : enums.PositionOnMap) -> enums.PositionOnMap:
	match(position):
		enums.PositionOnMap.DOWN:
			return enums.PositionOnMap.UP
		enums.PositionOnMap.UP:
			return enums.PositionOnMap.DOWN
		enums.PositionOnMap.LEFT:
			return enums.PositionOnMap.RIGHT
		enums.PositionOnMap.RIGHT:
			return enums.PositionOnMap.LEFT
		_ :
			return enums.PositionOnMap.MIDDLE

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
		
	_map = _mapGenerator.GenerateMap(self)
	_mapDimensions = _map.dimensions
	add_child(_map)
	
	for pickable in _map.GetPickables():
		pickable.picked_consumable.connect(OnPickedConsumable)
	
	for monkey in _strayMonkeys:
		monkey.GetTile().LeaveTile(monkey)
	_strayMonkeys.clear()
	_strayMonkeys.append_array(_map.GetStrays())
	for monkey in _strayMonkeys:
		monkey.JoinedGroup.connect(OnMonkeyJoinGroup)
		monkey.GotEaten.connect(OnMonkeyEaten)
	
	_ennemies.clear()
	_ennemies.append_array(_map.GetEnemies())	
	
func _set_leader_position():
	match arrived_from:
		enums.PositionOnMap.UP:
			leader.position =  Vector3(-round(_mapDimensions[0]/2) + 1, 0, 0)
		enums.PositionOnMap.DOWN:
			leader.position = Vector3(round(_mapDimensions[0]/2), 0, 0)
		enums.PositionOnMap.LEFT:
			leader.position = Vector3(0, 0, round(_mapDimensions[1]/2))
		enums.PositionOnMap.RIGHT:
			leader.position = Vector3(0, 0, - round(_mapDimensions[1]/2) + 1)
		_:
			leader.position = Vector3(0, 0, 0)
	_entryPoint = leader.position
		
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
			var tile = _map.GetTilefromVec(directPosition)
			if (tile != null):
				tiles.append(tile)
		var opposite = monkey.GetTilePosition() - pattern
		if (IsInMap(opposite)):
			var tile = _map.GetTilefromVec(opposite)
			if( tile != null):
				tiles.append(_map.GetTilefromVec(opposite))
			
	return tiles

func IsInMap(position : Vector2) -> bool:
	if (position.x < - _mapDimensions.x /2 + 1 && position.x > _mapDimensions.x / 2):
		return false
	if (position.y < - _mapDimensions.y /2 + 1 && position.y > _mapDimensions.y / 2):
		return false
		
	return true

func OnNightStart():
	$NightSound.play()	
	AudioServer.set_bus_volume_db(1, -12)
	
	ColobsManager.ResolveHunger()
	# pinpoint dead monkey(s)
	_gameUi.DisplayNightScreen()
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = true

func OnNightEnd():
	print("night ended")
	AudioServer.set_bus_volume_db(1, -6)
	if monkeys.size() == 0:
		_gameUi.GameOverScreen()
