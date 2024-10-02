extends Control

var _isOn : bool = true
var _currentvolume : float = 100

func _ready():
	_isOn = SoundsettingsManager.IsOn()
	_currentvolume = SoundsettingsManager.GetSettingsVolume() * 100
	

func _on_button_mouse_entered():
	$VBoxContainer/VSlider.show()


func _on_button_mouse_exited():
	$VBoxContainer/VSlider.hide()
