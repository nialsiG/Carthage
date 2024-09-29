extends Node
class_name LevelProvider

const enums = preload("res://Singletons/enums.gd")

func IsWin(level : int):
	return level > 7

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
	if level < 3:
		return enums.BiomeType.FOREST
	if level < 5:
		return enums.BiomeType.SAVANNAH

	return enums.BiomeType.BRACKISH

func UseLevelProvider() -> bool:
	return true

func GetTutorial(level : int) -> String:
	if (level == 0):
		return "Bienvenue, cher colobe, dans l’ère Tortonien.\nPour avoir une chance d’évoluer dans le temps :\n - Nourris-toi de ces aliments pour survivre aux aléas de la nuit\n - Sors de cet environnement pour en trouver un plus propice\r"

	if (level == 1):
		return "Les colobes sont des singes qui forment des groupes !\rTrouvez différentes espèces de colobes pour vous déplacer différemment.\rLes singes forestiers se déplacent sur les arbres en plus du sol.\rVous vous déplacez selon les capacités de votre singe leader. Pour changer de leader, cliquez sur un autre singe.\r\rChaque espèce a des aliments préférés qui les nourriront davantage."
	if (level == 2):
		return "Un prédateur !\rEn plus de vous nourrir avant la nuit, vous devrez esquiver les prédateurs pour sortir de cet environnement. Ils se déplacent après chaque déplacement de singe selon une ronde qui leur est propre. Déplacez-vous de manière efficace pour voyager et dans les environnements et dans les ères.\r"
	#if (level > 3):
	#	return "Niveau aléatoire"
	return ""
