class_name NightScreen extends Control

const enums = preload("res://Singletons/enums.gd")

var dead_monkeys: Array[Monkey]

@onready var monkey_faces: MonkeyFaces = $ColorRect/VBoxContainer/MonkeyFaces
@onready var end_button: Button = $ColorRect/EndNightButton

signal EndNight(dead_monkeys: Array[Monkey])

func _ready():
	end_button.grab_focus()
	ColobsManager.dead_monkeys_list.connect(OnDeadMonkeysPublished)

func OnDeadMonkeysPublished(deadMonkeys : Array[Monkey], reasons : Array[enums.PickableType]):
	if (deadMonkeys.size() == 0):
		monkey_faces.hide()
		$ColorRect/VBoxContainer/Label.text = "La nuit est tombée...\nTous les singes ont pu manger à leur faim. Tous ont survécu !"
	else:
		var desc = "La nuit est tombée...\n"
		if reasons.size() == 1:
			desc+="Il n'y a pas eu assez d"+GetDescSingular(reasons[0])+".\n"
		else:
			var missingFood = "Le groupe a manqué"			
			for pickable in reasons:
				missingFood += GetDesc(pickable)+", "
			missingFood.substr(0, missingFood.length()-1)
			desc += missingFood+"\n"
		if deadMonkeys.size() == 1:
			$ColorRect/VBoxContainer/Label.text = desc + deadMonkeys[0].Name+" est mort..."
		else:
			var deadMonkeysDesc : String = ""
			for i in deadMonkeys.size()-1:
				deadMonkeysDesc+=deadMonkeys[i].Name+", "
			deadMonkeysDesc = deadMonkeysDesc.substr(0, deadMonkeysDesc.length()-2)
			deadMonkeysDesc+=" et "+deadMonkeys[deadMonkeys.size()-1].Name+" sont morts..."
			$ColorRect/VBoxContainer/Label.text = desc + deadMonkeysDesc
		monkey_faces.Update(deadMonkeys) 
		monkey_faces.show()
	dead_monkeys = deadMonkeys

func GetDesc(pickable : enums.PickableType) -> String:
	match(pickable):
		enums.PickableType.LEAF:
			return "des feuilles"
		enums.PickableType.GRAIN:
			return " de l'herbe"
		enums.PickableType.FRUIT:
			return "des fruits"
	return ""

func GetDescSingular(pickable : enums.PickableType) -> String:
	match(pickable):
		enums.PickableType.LEAF:
			return "e feuilles"
		enums.PickableType.GRAIN:
			return "'herbe"
		enums.PickableType.FRUIT:
			return "e fruits"
	return ""
	
func _on_end_night_button_pressed():
	EndNight.emit(dead_monkeys)
	get_tree().paused = false
