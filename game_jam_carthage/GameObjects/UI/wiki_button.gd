class_name  WikiButton extends Button

@export var _texture: Texture2D = null
@export var _title: String = ""
@export_multiline var _text: String = ""

func _ready():
	self.text = _title
