extends Node
class_name GameScreen

const enums = preload("res://Singletons/enums.gd")

@onready var elements : Node3D = $Elements
@onready var mousePositionLabel : Label =  $Label
@onready var _ground : Node3D = $Ground
@onready var _mapGenerator : MapGenerator = $MapGenerator

#var _tiles : Array[TileMap] = []
var _map : Map
var monkeys :Array[Monkey] = []
var leader : Monkey
var _focusTile : MapTile
var turn : int = 1
var hoveredTile : Vector3 = Vector3.ZERO
var _mapDimensions : Vector2 = Vector2(20, 20)

const InvalidMoveVector : Vector3 = Vector3(-10000, 0,-10000)

var arrived_from: enums.PositionOnMap = enums.PositionOnMap.RIGHT
var current_position_on_map: enums.PositionOnMap


func _ready():
	_map = _mapGenerator.GenerateMap(self, _mapDimensions)
	
	var leader_start_position: Vector3 
	match arrived_from:
		enums.PositionOnMap.UP:
			leader_start_position = Vector3(round(_mapDimensions[0]/2), 0, 0)
		enums.PositionOnMap.DOWN:
			leader_start_position = Vector3(-round(_mapDimensions[0]/2) + 1, 0, 0)
		enums.PositionOnMap.LEFT:
			leader_start_position = Vector3(0, 0, -round(_mapDimensions[1]/2) + 1)
		enums.PositionOnMap.RIGHT:
			leader_start_position = Vector3(0, 0, round(_mapDimensions[1]/2))
	add_child(_map)
	
	for pickable in _map.GetPickables():
		pickable.picked_consumable.connect(OnPickedConsumable)
	
	for element in elements.get_children():
		if (element is Monkey):
			var tile = _map.GetTilefromVec(Vector2(element.position.x, element.position.z))
			element.SetTile(tile)
			if(element.IsLeader() && leader == null):
				leader = element
				leader.position = leader_start_position
				leader.SetTile(_map.GetTilefromVec(ConvertPositionToTile(leader.position)))
			if (!element.IsStray()):
				monkeys.append(element)

	if (leader == null):
		leader = monkeys[0]
		leader.SetLeader()
		leader.position = leader_start_position
	
func _process(delta):
	CheckLeaderMove()
	
func OnPickedConsumable(pickable_type : enums.PickableType):
	ColobsManager.PickItem(pickable_type)
	
func CheckLeaderMove() -> bool:
	var hasMoved = false
	if(Input.is_action_just_pressed("Left")):
		Move(leader, Vector3.LEFT)
		
	if(Input.is_action_just_pressed("Right")):
		Move(leader, Vector3.RIGHT)
		
	if(Input.is_action_just_pressed("Top")):
		Move(leader, Vector3.FORWARD)

	if (Input.is_action_just_pressed("Down")):
		Move(leader, Vector3.BACK)
		
	return hasMoved

signal MousePosition(position : Vector2)

func TryGrabFocus(tile : MapTile)-> bool:
	var distance = (leader.GetTilePosition() - tile.GetTile()).length()
	var isValid = true
	print(str(tile.GetTile())+" "+str(distance))
	if (distance != 1):
		isValid = false
	
	var mapITems = tile.GetMapItems()
	var obstacle : Obstacle
	for item in mapITems:
		if item is Obstacle:
			obstacle = item
	
	if obstacle != null:
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
	if (_focusTile == null):
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
				print("next scene")
				# TODO: next scene instantiation here
		turn += 1
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
