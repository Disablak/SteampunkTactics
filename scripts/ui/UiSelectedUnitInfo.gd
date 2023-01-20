class_name UiSelectedUnitInfo
extends Control


@onready var rich_text_label: RichTextLabel = get_node("RichTextLabel")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalBus.on_unit_died.connect(func(unit_id): clear())


func init():
	set_text("")


func set_text(text):
	clear()
	rich_text_label.add_text(text)


func clear():
	rich_text_label.clear()
