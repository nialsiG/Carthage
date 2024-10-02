extends Button

@export var onImage : Texture2D
@export var offImage : Texture2D

var _isOn : bool = true

func _ready():
	setValue(SoundsettingsManager.IsOn())

func OnSoundUpdated(value : float):
	setValue(value > 0)

func setValue(value : bool):
	_isOn = value
	if (_isOn):
		icon = onImage
	else:
		icon = offImage
	SoundsettingsManager.SetOnOff(_isOn)


func _on_pressed():
	setValue(!_isOn)
