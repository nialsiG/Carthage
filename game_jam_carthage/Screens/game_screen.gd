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

func _ready():
	_map = _mapGenerator.GenerateMap(self, _mapDimensions)
	add_child(_map)
	
	for pickable in _map.GetPickables():
		pickable.picked_consumable.connect(OnPickedConsumable)
	
	for element in elements.get_children():
		if (element is Monkey):
			var tile = _map.GetTilefromVec(Vector2(element.position.x, element.position.z))
			element.SetTile(tile)
			if(element.IsLeader() && leader == null):
				leader = element
				leader.SetTile(_map.GetTilefromVec(ConvertPositionToTile(leader.position)))
			if (!element.IsStray()):
				monkeys.append(element)

	if (leader == null):
		leader = monkeys[0]
		leader.SetLeader()
	
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
		turn += 1
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
