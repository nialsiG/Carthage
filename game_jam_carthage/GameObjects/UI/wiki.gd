class_name  Wiki extends Control

@export var button_array: Array[WikiButton]
@onready var text_label: RichTextLabel = %WikiRichTextLabel
@onready var texture_rect: TextureRect = %WikiTextureRect

signal CloseWiki

func _ready():
	for button in button_array:
		button.focus_entered.connect(change_wiki.bind(button._title, button._text, button._texture))

func change_wiki(title: String, text: String, texture: Texture2D):
	text_label.text = text
	texture_rect.texture = texture

func GrabFocus():
	button_array[0].grab_focus()

func _on_wiki_return_button_pressed():
	CloseWiki.emit()
