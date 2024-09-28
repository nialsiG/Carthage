extends Node
class_name GameScreen

@onready var elements : Node3D = $Elements
@onready var mousePositionLabel : Label =  $Label

var monkeys :Array[Monkey] = []
var leader : Monkey
var turn : int = 1
var hoveredTile : Vector3 = Vector3.ZERO

const InvalidMoveVector : Vector3 = Vector3(-10000, 0,-10000)

func _ready():
	for element in elements.get_children():
		if (element is Monkey):
			if(element.IsLeader()):
				leader = element
			if (!element.IsStray()):
				monkeys.append(element)

	if (leader == null):
		leader = monkeys[0]
		leader.SetLeader()
	
func OnMoved():
	turn+=1

func _process(delta):
	var move = CheckLeaderMove()

func CheckLeaderMove() -> bool:
	var hasMoved = false
	if(Input.is_action_just_pressed("Left")):
		leader.position = leader.position + Vector3.LEFT
		
	if(Input.is_action_just_pressed("Right")):
		leader.position = leader.position + Vector3.RIGHT
		
	if(Input.is_action_just_pressed("Top")):
		leader.position = leader.position + Vector3.FORWARD

	if (Input.is_action_just_pressed("Down")):
		leader.position = leader.position +Vector3.BACK
		
	return hasMoved

signal MousePosition(position : Vector2)

func _on_ground_input_event(camera, event, event_position, normal, shape_idx):
	leader.LightUp(Vector2(event_position.x, event_position.z))
	var newPos = GetTile(event_position)	
	if (newPos != hoveredTile):
		print("event position "+ str(event_position))
		hoveredTile = newPos
		print(str(hoveredTile))
	
	mousePositionLabel.text = str(hoveredTile.x)+":"+str(hoveredTile.y)
		
func _input(event):
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT):
		var positionDiff = hoveredTile -GetTile(leader.position)
		print(str(positionDiff))
		if (positionDiff.length() <= 1):
			leader.position = leader.position + positionDiff 

func GetTile(tilePosition : Vector3) -> Vector3:
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
		
	return Vector3(x, 0, z)
