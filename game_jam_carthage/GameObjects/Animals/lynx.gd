extends Ennemy
class_name Lynx

func ControlLeft() -> bool:
	return _lookLeft
	
func ControlRight() -> bool:
	return !_lookLeft

func UpdateDangerZone():
	if (satiated > 0):
		$DangerZoneRight.hide()
		$DangerZoneMiddle.hide()
		$DangerZoneLeft.hide()
	elif (!_lookLeft):
		$DangerZoneLeft.show()
		$DangerZoneMiddle.show()
		$DangerZoneRight.hide()
	else:
		$DangerZoneLeft.hide()
		$DangerZoneMiddle.show()
		$DangerZoneRight.show()
