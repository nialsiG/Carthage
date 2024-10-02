extends Node

var _isOn : bool = true
var _currentVolume : float = -12
 
signal SwitchedOnOff(isOn : bool)
signal UpdatedVolume(dBValue : float)


func _ready():
	$Intro.finished.connect(OnIntroFinished)

func Start():
	$Intro.play()

func OnIntroFinished():
	$Intro.stop()
	$MainLoop.play()
	$MainLoop.finished.connect(OnMainLoopFinished)

func OnMainLoopFinished():
	$MainLoop.play()
	
func StartAmbiance():
	$Ambiance.play()

func Death():
	$MainLoop.stop()
	$Ambiance.stop()
	
func Win():
	$MainLoop.stop()
	$Ambiance.stop()
	$Win.play()
	
func IsOn() -> bool:
	return _isOn

func GetCurrentVolume() -> float:
	return _currentVolume

func SetOnOff(isOn : bool):
	_isOn = isOn
	SwitchedOnOff.emit(_isOn)

func GetSettingsVolume() -> float:
	return db_to_linear(_currentVolume + 6)

func UpdateValue(value : float): #expects value between 0 and 1
	_currentVolume = linear_to_db(value) -6
	UpdatedVolume.emit(_currentVolume)
