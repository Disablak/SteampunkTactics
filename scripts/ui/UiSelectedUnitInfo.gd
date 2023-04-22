class_name UiSelectedUnitInfo
extends Control


@onready var rich_text_label: RichTextLabel = get_node("RichTextLabel")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalBus.on_unit_died.connect(func(unit_id, tmp): hide_panel())


func init():
	hide_panel()


func set_text(text):
	visible = true
	rich_text_label.clear()
	rich_text_label.add_text(text)


func hide_panel():
	visible = false
