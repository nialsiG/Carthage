extends Node
class_name BandManager

var _band : Array[Monkey] = []
var _deadMonkeysFromFood : int = 0
var _deadMonkeysFromBeast : int = 0
var _numberOfScenesSurvived : int = 0
var _pickedFood : int = 0
var _currentBiome : enums.BiomeType = enums.BiomeType.FOREST
var _currentLevel : int= 0

signal dead_monkeys_list(dead_monkeys: Array[Monkey],
						 dead_monkeys_reason: Array[enums.PickableType])

const enums = preload("res://Singletons/enums.gd")
@onready var _inventory: Inventory = $Inventory
@onready var _monkeyGenerator: MonkeyGenerator = $MonkeyGenerator
@onready var _levelProvider: LevelProvider = $LevelProvider
@onready var game_scene =  "res://Screens/WinScreen.tscn"

var _surroundingBiomes : Dictionary

var biomesAvailableFromForest : Array[enums.BiomeType] = [enums.BiomeType.FOREST,
	enums.BiomeType.FOREST,
	enums.BiomeType.FOREST,
	enums.BiomeType.FOREST,
	enums.BiomeType.FOREST,
	enums.BiomeType.FOREST,
	enums.BiomeType.FOREST,
	enums.BiomeType.SAVANNAH,
	enums.BiomeType.SAVANNAH,
	enums.BiomeType.SAVANNAH,
	enums.BiomeType.BRACKISH,
	enums.BiomeType.BRACKISH,
	enums.BiomeType.BRACKISH]

var pickablePriorityForForest : Array[enums.PickableType] = [enums.PickableType.LEAF, enums.PickableType.GRAIN, enums.PickableType.FRUIT]
var pickablePriorityForSavannah : Array[enums.PickableType] = [enums.PickableType.GRAIN, enums.PickableType.FRUIT, enums.PickableType.LEAF]
var pickablePriorityForBrackish : Array[enums.PickableType] = [enums.PickableType.LEAF, enums.PickableType.GRAIN, enums.PickableType.FRUIT]

@export var _initialDyingRate: float = 0.75

signal FoodPicked(food: enums.PickableType, amount: int)
signal FoodRemoved(food: enums.PickableType, amount: int)

func _ready():
	randomize()

func InitializeGame():
	_band = []
	_currentLevel = 0
	_deadMonkeysFromFood = 0
	_deadMonkeysFromBeast = 0
	_pickedFood = 0
	var monkey = _monkeyGenerator.GenerateStarterMonkey()
	monkey.SetLeader()
	_band.append(monkey)
	_numberOfScenesSurvived = 0
	_currentBiome = enums.BiomeType.FOREST
	GenerateNewCurrentBiome()
	
func PushMonkeys(monkeys : Array[Monkey]):
	_band = monkeys
	
func PullMonkeys() -> Array[Monkey]:
	return _band

func PickItem(pickable : enums.PickableType):
	_pickedFood+=1
	_inventory._on_pickable_reveived(pickable)
	FoodPicked.emit(pickable, _inventory.inventory[enums.PickableType.find_key(pickable)])
	print("food picked : ")

func MonkeyDied(monkey : Monkey, Death):
	_deadMonkeysFromBeast+=1

func LeftScene(direction : enums.PositionOnMap) -> bool:
	_numberOfScenesSurvived+=1
	_currentBiome = _surroundingBiomes[direction]
	_currentLevel += 1
	
	if (_levelProvider.IsWin(_currentLevel)):
		get_tree().change_scene_to_file(game_scene)
		return false
	
	GenerateNewCurrentBiome()
	return true
	
func GenerateNewCurrentBiome():
	_currentBiome = _levelProvider.GetBiome(_currentLevel)
	var nextBiome = _levelProvider.GetBiome(_currentLevel + 1)
	_surroundingBiomes[enums.PositionOnMap.MIDDLE] = _currentBiome
	_surroundingBiomes[enums.PositionOnMap.LEFT] = nextBiome
	_surroundingBiomes[enums.PositionOnMap.UP] = nextBiome
	_surroundingBiomes[enums.PositionOnMap.RIGHT] = nextBiome
	_surroundingBiomes[enums.PositionOnMap.DOWN] = nextBiome

func GetSurroundingBiome(direction : enums.PositionOnMap) -> enums.BiomeType:
	return _surroundingBiomes[direction as enums.PositionOnMap] as enums.BiomeType

func GetPickableForBiome() -> enums.PickableType:
	var randomValue = randf_range(0,100)
	var refTable : Array[enums.PickableType]
	if (_currentBiome == enums.BiomeType.FOREST):
		refTable = pickablePriorityForForest
	elif (_currentBiome == enums.BiomeType.SAVANNAH):
		refTable = pickablePriorityForSavannah
	elif(_currentBiome == enums.BiomeType.BRACKISH):
		refTable = pickablePriorityForBrackish
	
	if (randomValue < 45):
		return refTable[0]
	elif (randomValue <75):
		return refTable[1]
	return refTable[2]

func ResolveHunger():
	var dying_rate = _initialDyingRate
	var inventory: Dictionary = _inventory.inventory
	var dead_monkeys: Array[Monkey] = []
	var dead_monkeys_reason: Array[enums.PickableType] = []
	for monkey in _band:
		var isFed = false
		for diet in monkey._diet:
			if (isFed):
				continue
			var pickable = (diet as enums.PickableType)
			var pickableKey = enums.PickableType.keys()[pickable]
			if inventory[pickableKey] >= 1:
				isFed = true
				inventory[pickableKey] -= 1
				if inventory[pickableKey] < 0:
					inventory[pickableKey] = 0
		if !isFed: # possible death
			var rand: float = randf()
			if rand < _initialDyingRate:
				dead_monkeys.append(monkey)
				_deadMonkeysFromFood+=1
				for pickable in monkey._diet:
					if (dead_monkeys_reason.find(pickable) == -1):
						dead_monkeys_reason.append(pickable)

				
	print("dead_monkeys ", dead_monkeys)
	print("inventory after night", inventory)
	_inventory.inventory = inventory
	dead_monkeys_list.emit(dead_monkeys, dead_monkeys_reason)
				
func GetLevel() -> String:
	return _levelProvider.GetPath(_currentLevel)

func GetTutoriel() -> String:
	return _levelProvider.GetTutorial(_currentLevel)

func GetPeriod() -> enums.PeriodType:
	return _levelProvider.GetPeriod(_currentLevel)

func GetCurrentBiome() -> enums.BiomeType:
	return _currentBiome

func GetBiomeFauna() -> Array[enums.Enemies]:
	if (_currentBiome == enums.BiomeType.FOREST):
		return [enums.Enemies.REDPANDA]
	elif (_currentBiome == enums.BiomeType.SAVANNAH):
		return [enums.Enemies.REDPANDA, enums.Enemies.LYNX, enums.Enemies.LYNX, enums.Enemies.LYNX]
	else:
		return [enums.Enemies.REDPANDA, enums.Enemies.LYNX, enums.Enemies.LYNX, enums.Enemies.LYNX, enums.Enemies.LYNX, enums.Enemies.LYNX]

func GetBiomeObstacle() -> Array[enums.ObstableType]:
	if (_currentBiome == enums.BiomeType.FOREST):
		return [enums.ObstableType.TREE, enums.ObstableType.TREE, enums.ObstableType.ROCK]
	elif (_currentBiome == enums.BiomeType.SAVANNAH):
		return [enums.ObstableType.TREE, enums.ObstableType.ROCK, enums.ObstableType.ROCK, enums.ObstableType.ROCK, enums.ObstableType.ROCK]
	else:
		return [enums.ObstableType.TREE, enums.ObstableType.TREE, enums.ObstableType.ROCK, enums.ObstableType.ROCK,  enums.ObstableType.ROCK, enums.ObstableType.ROCK, enums.ObstableType.TREE, enums.ObstableType.TREE, enums.ObstableType.ROCK, enums.ObstableType.ROCK, enums.ObstableType.ROCK, enums.ObstableType.ROCK, enums.ObstableType.SWAMP]

func GetRandomDimensions() -> Vector2:
	var width = 10 + 2 * _currentLevel
	return Vector2(width, width)
