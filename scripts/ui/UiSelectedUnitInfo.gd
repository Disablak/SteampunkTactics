class_name UiSelectedUnitInfo
extends Control


@onready var rich_text_label: RichTextLabel = get_node("RichTextLabel")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func init():
	set_text("")


func set_text(text):
	rich_text_label.text = text


func clear():
	rich_text_label.clear()
