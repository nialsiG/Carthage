extends Node
class_name GameScreen

@onready var elements : Node3D = $Elements
@onready var mousePositionLabel : Label =  $Label
@onready var _ground : Node3D = $Ground

var tilePS = preload("res://GameObjects/Ground/MapTile.tscn")
var baseMaterial = preload("res://Assets/Materials/DefaultGround.tres")

var monkeys :Array[Monkey] = []
var leader : Monkey
var _focusTile : MapTile
var turn : int = 1
var hoveredTile : Vector3 = Vector3.ZERO
var _mapDimensions : Vector2 = Vector2(20, 20)

const InvalidMoveVector : Vector3 = Vector3(-10000, 0,-10000)

func _ready():
	GenerateMap(_mapDimensions)
	
	for element in elements.get_children():
		if (element is Monkey):
			var tile = GetTile(element.position)
			element.SetTile(tile)
			if(element.IsLeader() && leader == null):
				leader = element
				leader.SetTile(GetTile(leader.position))
			if (!element.IsStray()):
				monkeys.append(element)

	if (leader == null):
		leader = monkeys[0]
		leader.SetLeader()
	
func _process(delta):
	if CheckLeaderMove():
		turn += 1
		
func GenerateMap(dimensions : Vector2):
	var width = int(dimensions.x)
	var height = int(dimensions.y)
	for x in width:
		for y in height:
			var tile = tilePS.instantiate()
			_ground.add_child(tile)
			tile.Initialize(self, Vector2(x - (width / 2) + 1, y - (height / 2) + 1), baseMaterial)
			tile.position = Vector3(x + 0.5 - width / 2, 0, y + 0.5 - height / 2)
			
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
	var distance = (leader.GetTile() - tile.GetTile()).length()
	var isValid = true 
	print(str(tile.GetTile())+" "+str(distance))
	if (distance != 1):
		isValid = false
	
	#Check tile available for move (occupied or collision)
	if (_focusTile != null):
		_focusTile.ReleaseFocus()
		
	_focusTile = tile
	return isValid
		
func _input(event):
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT):
		print("Right click")
		var positionDiff = _focusTile.GetTile() - leader.GetTile()
		print("Diff position: "+str(positionDiff))
		if (positionDiff.length() <= 1):
			Move(leader, Vector3(positionDiff.x, 0, positionDiff.y))

func Move(target : Node3D, positionDiff : Vector3):
	target.position = leader.position + positionDiff
	target.SetTile(GetTile(target.position))
	_focusTile.ReleaseFocus()
	
func GetTile(tilePosition : Vector3) -> Vector2:
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
