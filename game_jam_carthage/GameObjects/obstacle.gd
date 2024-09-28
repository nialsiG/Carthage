extends MapItem
class_name Obstacle

const enums = preload("res://Singletons/enums.gd")

@export var obstacle_type: enums.ObstableType = enums.ObstableType.ROCK
