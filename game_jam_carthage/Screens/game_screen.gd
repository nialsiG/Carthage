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
@onready var _camera = $Camera3D
var _waitingForReactions : bool = false
var waitDurationBetweenActions : float = 0.1
var _entryPoint : Vector3 = Vector3.ZERO
var _moveSound : int = 0
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
	SoundsettingsManager.StartAmbiance()
	ColobsManager.InitializeGame()
	monkeys = ColobsManager.PullMonkeys()
	makeNewMap()
	
	for monkey in monkeys:
		if monkey.IsLeader():
			leader = monkey
		elements.add_child(monkey)
		monkey.GotEaten.connect(OnMonkeyEaten)
		monkey.GrabLeaderShip.connect(OnGrabLeaderShip)
	leader.SetTile(_map.GetTilefromVec(ConvertPositionToTile(leader.position)))
	AttachCamera(leader)
	
	# Initial update UI
	_gameUi.UpdateMonkeyFaces(monkeys)
	_gameUi.UpdateTurnCounter(turn)
	_gameUi.UpdatePeriod(enums.PeriodType.TORTONIAN)
	_gameUi.connect("EndNight", OnNightEnd)
	_nightscreen.connect("night_time", OnNightStart)

func AttachCamera(monkey : Monkey):
	_camera.SetFollowedObject(monkey)
			
func _process(delta):
	if(_waitingForReactions):
		return
	CheckLeaderMove()

func OnGrabLeaderShip(monkey : Monkey):
	if (leader!=null):
		leader.StealLeadership()
	var isOldLeaderStillLeader = leader.IsLeader()
	monkey.SetLeader()
	leader = monkey
	AttachCamera(leader)
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
		
	if monkeys.size() == 0:
		_waitingForReactions = true
		ColobsManager.MonkeyDied(monkey, enums.DeathCause.BEAST)
		await Wait(2.0)
		_gameUi.GameOverScreen()
		SoundsettingsManager.Death()
		
	if (leader == null) and monkeys.size() > 0:
		leader = monkeys[0]
		leader.SetLeader()
	_gameUi.UpdateMonkeyFaces(monkeys)
	
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
	if (!leader.CanMoveThrough(obstructionType, true)):
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
		else:
			$InefficientClickSound.play()
	
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		$InefficientClickSound.play()

func Move(target : MapItem, positionDiff : Vector3):
	PlayMoveSound()
	var targetPosition = target.position + positionDiff
	target.Move(targetPosition)
	target._flip_h(positionDiff)
	var tile = _map.GetTilefromVec(ConvertPositionToTile(targetPosition))
	if tile:
		var items = tile.GetMapItems()
		target.InteractWithItem(items)
		if (target is Ennemy):
			var left = targetPosition - Vector3(1, 0, 0)
			var right = targetPosition + Vector3(1, 0, 0)
			var leftTile = _map.GetTilefromVec(Vector2(left.x, left.z))
			var rightTile = _map.GetTilefromVec(Vector2(right.x, right.z))
			if (leftTile != null):
				target.InteractWithSideItem(leftTile.GetMapItems(), true)
			if (rightTile != null):
				target.InteractWithSideItem(rightTile.GetMapItems(), false)
		target.SetTile(tile)
	if _focusTile:
		_focusTile.ReleaseFocus()
		
	if (target  == leader):
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
						monkey.position = Vector3(-100,0,-100)
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
		_gameUi.UpdateMonkeyFaces(monkeys)
		
	for monkey in _strayMonkeys:
		var move = monkey.React(leader, GetAvailableMoveTiles(monkey))
		
	for ennemy in _ennemies:
		await Wait(waitDurationBetweenActions)
		var move = ennemy.GetMovement()
		if move:
			Move(ennemy, move)
			ennemy.UpdateDangerZone()
		
	_waitingForReactions = false
	if (target == leader):
		IncrementTurn()

func IncrementTurn():
	turn += 1
	_gameUi.UpdateTurnCounter(turn)
	$Night._on_new_turn(turn)

func PlayMoveSound():
	if (_moveSound == 0):
		$MonkeyMove.play()
	elif(_moveSound == 1):
		$MonkeyMove2.play()
	elif (_moveSound == 2):
		$MonkeyMove3.play()
	_moveSound = (_moveSound + 1) % 3
	
func CheckLeader():
	var hasLeader : bool = false
	for monkey in monkeys:
		if (monkey.IsLeader()):
			hasLeader = true
			
	if(!hasLeader && monkeys.size() > 0):
		monkeys[0].SetLeader()
		leader = monkeys[0]
	

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
	if _map.GetTile(leader_position.x, leader_position.y).IsBorder():
		return enums.PositionOnMap.UP
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
	
	_gameUi.TutorialScreen(ColobsManager.GetTutoriel())
	_gameUi.UpdatePeriod(ColobsManager.GetPeriod())
	_ennemies.clear()
	_ennemies.append_array(_map.GetEnemies())	
	
func _set_leader_position():
	leader.InterruptMovement()
	leader.position =  Vector3(0, 0, round(_mapDimensions[1]/2))
	_entryPoint = leader.position
		
func ConvertPositionToTile(tilePosition : Vector3) -> Vector2:
	var x = 0
	var z = 0

	x = snapped(tilePosition.x, 1)
	if (tilePosition.x < 0 && tilePosition.x  > x + 1):
		x += -1
	elif (tilePosition.x > 0 && tilePosition.x < x ):
		x += 1
		
	z = snapped(tilePosition.z, 1)	
	if (tilePosition.z < 0 && tilePosition.z > z + 1):
		z += -1
	elif (tilePosition.z > 0 && tilePosition.z < z ):
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

func OnNightEnd(dead_monkeys : Array[Monkey]):
	var indexShift : int = 0
	for monkey in dead_monkeys:
		monkey.GetTile().LeaveTile(monkey)
		monkeys.erase(monkey)
		if (monkey.IsLeader()):
			monkey.StealLeadership()
		monkey.queue_free()
		
	_gameUi.UpdateFoodScreen()
	CheckLeader()
	AudioServer.set_bus_volume_db(1, -6)
	_gameUi.UpdateMonkeyFaces(monkeys)
	if monkeys.size() == 0:
		_gameUi.GameOverScreen()
		SoundsettingsManager.Death()
