extends Node
class_name LevelProvider

const enums = preload("res://Singletons/enums.gd")

func IsWin(level : int):
	return level > 7

func GetPath(level : int) -> String:
	match(level):
		0:
			return "res://Assets/Levels/Tuto1.json"
		1:
			return "res://Assets/Levels/Tuto2.json"
		2:
			return "res://Assets/Levels/Tuto3.json"
		3:
			return "res://Assets/Levels/MidLevel1.json"
		4:
			return "res://Assets/Levels/MidLevel1.json"
		5:
			return "res://Assets/Levels/MidLevel2.json"			
		6:
			return "res://Assets/Levels/EndLevel1.json"
		7:
			return "res://Assets/Levels/EndLevel2.json"
	return ""
	
func GetBiome(level: int) -> enums.BiomeType:
	if level < 3:
		return enums.BiomeType.FOREST
	if level < 5:
		return enums.BiomeType.SAVANNAH

	return enums.BiomeType.BRACKISH

func UseLevelProvider() -> bool:
	return false

func GetTutorial(level : int) -> String:
	if (level == 0):
		return "Déplacer vous vers un bord d'un écran"
	if (level == 1):
		return "level 2 TUTO"
	if (level == 2):
		return "level 3 TUTO"
	else:
		return ""
