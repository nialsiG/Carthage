extends Node
class_name LevelProvider

const enums = preload("res://Singletons/enums.gd")
const _forestLimit : int = 3
const _SavannahLimit : int = 4
const _winLevel = 11
func IsWin(level : int):
	return level >= _winLevel

func GetPath(level : int) -> String:
	match(level):
		0:
			return "res://Assets/Levels/LevelTuto1.json"
		1:
			return "res://Assets/Levels/LevelTuto2.json"
		2:
			return "res://Assets/Levels/LevelTuto3.json"

	return ""
	
func GetBiome(level: int) -> enums.BiomeType:
	if (level == _winLevel):
		return enums.BiomeType.WIN

	if level < _forestLimit:
		return enums.BiomeType.FOREST
	if level < _SavannahLimit:
		return enums.BiomeType.SAVANNAH
	
	return enums.BiomeType.BRACKISH

func GetPeriod(level : int) -> enums.PeriodType:
	if level < _forestLimit:
		return enums.PeriodType.TORTONIAN
	else:
		return enums.PeriodType.MESSINIAN
		
func UseLevelProvider() -> bool:
	return true
