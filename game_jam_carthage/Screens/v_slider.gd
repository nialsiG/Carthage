extends VSlider

func _ready():
	value = SoundsettingsManager.GetSettingsVolume() * 100


func OnValueChanged(newValue : float):
	SoundsettingsManager.UpdateValue(newValue / 100)
