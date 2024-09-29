extends Node
class_name BandManager

var _band : Array[Monkey] = []
var _numberOfScenesSurvived : int = 0
var _currentBiome : enums.BiomeType = enums.BiomeType.FOREST

const enums = preload("res://Singletons/enums.gd")
@onready var _inventory: Inventory = $Inventory
@onready var _monkeyGenerator: MonkeyGenerator = $MonkeyGenerator

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

var pickablePriorityForForest : Array[enums.PickableType] = [enums.PickableType.LEAF, enums.PickableType.INSECT, enums.PickableType.GRAIN, enums.PickableType.FRUIT]
var pickablePriorityForSavannah : Array[enums.PickableType] = [enums.PickableType.INSECT, enums.PickableType.GRAIN, enums.PickableType.FRUIT, enums.PickableType.LEAF]
var pickablePriorityForBrackish : Array[enums.PickableType] = [enums.PickableType.INSECT, enums.PickableType.LEAF, enums.PickableType.GRAIN, enums.PickableType.FRUIT]

@export var _initialDyingRate: float = 0.75

signal FoodPicked(food: enums.PickableType, amount: int)
signal FoodRemoved(food: enums.PickableType, amount: int)

func _ready():
	pass

func InitializeGame():
	_band = []
	var monkey = _monkeyGenerator.GenerateStarterMonkey()
	monkey.position += Vector3(0.5, 0, 0.5)
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
	_inventory._on_pickable_reveived(pickable)
	FoodPicked.emit(pickable, _inventory.inventory[enums.PickableType.find_key(pickable)])
	print("food picked : ")

func MonkeyDied(monkey : Monkey, Death):
	pass

func LeftScene(direction : enums.PositionOnMap):
	_numberOfScenesSurvived+=1
	_currentBiome = _surroundingBiomes[direction]
	GenerateNewCurrentBiome()
	
func GenerateNewCurrentBiome():
	_surroundingBiomes[enums.PositionOnMap.MIDDLE] = _currentBiome
	_surroundingBiomes[enums.PositionOnMap.LEFT] = biomesAvailableFromForest.pick_random()
	_surroundingBiomes[enums.PositionOnMap.UP] = biomesAvailableFromForest.pick_random()
	_surroundingBiomes[enums.PositionOnMap.RIGHT] = biomesAvailableFromForest.pick_random()
	_surroundingBiomes[enums.PositionOnMap.DOWN] = biomesAvailableFromForest.pick_random()

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
	
	if (randomValue < 40):
		return refTable[0]
	elif (randomValue <70):
		return refTable[1]
	elif (randomValue < 90):
		return refTable[2]
	return refTable[3]

func ResolveDeath(monkey: Monkey):
	print("A monkey died!")

func ResolveHunger():
	var dying_rate = _initialDyingRate
	for m in _band:
		# search for edible food
		for food in m._diet:
			if _inventory.inventory.has(food):
				var delta = _inventory.inventory[food] - 0.75
				_inventory.inventory[food] -= 0.75
				break
		# if no edible food was found, eat food until dying rate = 0
		if dying_rate > 0:
			pass
		# if no more food, stop
		if dying_rate > 0:
			ResolveDeath(m)
