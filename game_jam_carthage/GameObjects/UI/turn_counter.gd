class_name TurnCounter extends Control

const _enums = preload("res://Singletons/enums.gd")

@onready var turn_label = %CurrentTurnLabel
@onready var period_label = %PeriodNameLabel

func UpdateTurn(amount: int):
	turn_label.text = "Tour " + str(amount)

func ChangePeriod(period: _enums.PeriodType):
	match period:
		_enums.PeriodType.TORTONIAN: 
			period_label.text = "Tortonien"
		_enums.PeriodType.MESSINIAN: 
			period_label.text = "Messinien"
