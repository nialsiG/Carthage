extends Node
class_name ObstacleFactory

const enums = preload("res://Singletons/enums.gd")

var rockPS = preload("res://GameObjects/Obstacle/Rock.tscn")
var rockPS_2 = preload("res://GameObjects/Obstacle/Rock2.tscn")
var rockPS_3 = preload("res://GameObjects/Obstacle/Rock3.tscn")
var rockPS_4 = preload("res://GameObjects/Obstacle/Rock4.tscn")
var tree_forest_1PS = preload("res://GameObjects/Obstacle/Tree_forest.tscn")
var tree_forest_2PS = preload("res://GameObjects/Obstacle/Tree_forest_2.tscn")
var tree_savannah_1PS = preload("res://GameObjects/Obstacle/Tree_savannah.tscn")
var tree_savannah_2PS = preload("res://GameObjects/Obstacle/Tree_savannah_2.tscn")
var pondPS = preload("res://GameObjects/Obstacle/Pond.tscn")

var forestTrees : Array[PackedScene] = [tree_forest_1PS, tree_forest_2PS]
var savannahTrees : Array[PackedScene] = [tree_savannah_1PS, tree_savannah_2PS]
var rocks : Array[PackedScene] = [rockPS, rockPS_2,rockPS_3,rockPS_4]

func CreateScene(obstacleType : enums.ObstableType, biome : enums.BiomeType) -> Obstacle:
	if (obstacleType == enums.ObstableType.TREE):
		if (biome == enums.BiomeType.FOREST):
			var ps = forestTrees.pick_random()
			return ps.instantiate()
		elif (biome == enums.BiomeType.SAVANNAH):
			var ps = savannahTrees.pick_random()
			return ps.instantiate()
		else:
			return tree_forest_1PS.instantiate()
	if obstacleType == enums.ObstableType.ROCK:
		return  rocks.pick_random().instantiate()
	else:
		return pondPS.instantiate()
