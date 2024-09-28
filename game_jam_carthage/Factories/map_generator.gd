extends Node
class_name MapGenerator

var tilePS = preload("res://GameObjects/Ground/MapTile.tscn")
var mapPS = preload("res://GameObjects/Ground/Map.tscn")
var baseMaterial = preload("res://Assets/Materials/DefaultGround.tres")
var obstaclePS = preload("res://GameObjects/Obstacle.tscn")
var pickablePS = preload("res://GameObjects/pickable.tscn")

func GenerateMap(gameScreen : GameScreen, dimensions : Vector2):
	var map = mapPS.instantiate() as Map
	var width = int(dimensions.x)
	var height = int(dimensions.y)
	for x in width:
		for y in height:
			var tile = tilePS.instantiate()
			map.AddTile(tile)
			tile.Initialize(gameScreen, Vector2(x - (width / 2) + 1, y - (height / 2) + 1), baseMaterial)
			tile.position = Vector3(x + 0.5 - width / 2, 0, y + 0.5 - height / 2)

	for i in 5:
		var x = randi_range(-dimensions.x / 2 + 1, dimensions.x / 2)
		var y = randi_range(-dimensions.y / 2 + 1, dimensions.y / 2)
		print ("pickable: "+str(x)+":"+str(y))
		var pickable = pickablePS.instantiate()
		map.AddPickable(pickable, Vector2(x, y))

	for i in 5:
		var x = randi_range(-dimensions.x / 2 + 1, dimensions.x / 2)
		var y = randi_range(-dimensions.y / 2 + 1, dimensions.y / 2)
		print ("pickable: "+str(x)+":"+str(y))
		var obstacle = obstaclePS.instantiate()
		map.AddObstacle(obstacle, Vector2(x, y))
	
	return map
