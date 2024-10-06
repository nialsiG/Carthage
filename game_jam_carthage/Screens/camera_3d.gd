extends Camera3D
class_name GameCamera

var _lerpSpeed : float = 0.05
var _followedMonkey : Monkey = null
var _recentering = true 
func SetFollowedObject(monkey : Monkey):
	_recentering = false
	_followedMonkey = monkey

func Recenter():
	_recentering = true
	_followedMonkey = null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (_recentering || _followedMonkey == null || _followedMonkey.is_queued_for_deletion()):	
		position = lerp(position, Vector3(0, position.y, 0), _lerpSpeed)
	else:
		position = lerp(position, Vector3(_followedMonkey.position.x, position.y, _followedMonkey.position.z+12), _lerpSpeed)
