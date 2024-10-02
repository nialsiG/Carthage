extends AudioStreamPlayer
class_name SoundSettingsSubscriber

@export var _dbOffset : float = 0

var _currentVolume : float = -6
var _isOn : bool = true

func _ready():
	_currentVolume = SoundsettingsManager.GetCurrentVolume()
	_isOn = SoundsettingsManager.IsOn()
	SoundsettingsManager.SwitchedOnOff.connect(OnSoundSwitched)
	SoundsettingsManager.UpdatedVolume.connect(OnSoundUpdated)
	_updateVolume()


func OnSoundSwitched(isOn : bool):
	_isOn = isOn
	_updateVolume()
	
func OnSoundUpdated(value : float):
	_currentVolume = value
	_updateVolume()
	
func _updateVolume():
	if (_isOn):
		volume_db = _currentVolume + _dbOffset
	else:
		volume_db = -100
