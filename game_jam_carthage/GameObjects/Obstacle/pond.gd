extends Obstacle
class_name Pond


# Called when the node enters the scene tree for the first time.
func _ready():
	var hideCrocodile = randf()
	if hideCrocodile < 0.66:
		$SM_Crocodile_01.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
