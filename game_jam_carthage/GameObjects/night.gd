class_name Night
extends Control


@export var number_of_turns_per_day:int = 20

var fully_day: int = ceil(number_of_turns_per_day * 0.75) 
var is_night: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_night = false
	visible = true
	$CanvasModulate.color.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_new_turn(current_turn: int):
	current_turn = current_turn % number_of_turns_per_day
	print("current_turn:", current_turn)
	if current_turn < fully_day:
		$CanvasModulate.color.a = 0
	# we did modulo
	elif current_turn == number_of_turns_per_day - 1:
		is_night = true
		print("night")
		$CanvasModulate.color.a = 1
		
	else:
		var variable_luminosity: float = number_of_turns_per_day - fully_day
		print(variable_luminosity)
		var counter: float = current_turn - fully_day + 1
		print(counter)
		var alpha: float = 1 - (variable_luminosity - counter) / variable_luminosity
		$CanvasModulate.color.a = alpha
		print(alpha)
	print("alpha", $CanvasModulate.color.a)
	
