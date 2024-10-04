extends Camera3D

var _followedMonkey : Monkey = null

func SetFollowedObject(monkey : Monkey):
	_followedMonkey = monkey

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (_followedMonkey == null || _followedMonkey.is_queued_for_deletion()):
		return
		
	position = lerp(position, Vector3(_followedMonkey.position.x, position.y, _followedMonkey.position.z+12), 0.05)
