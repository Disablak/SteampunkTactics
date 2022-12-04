class_name GUI
extends Control


@export var tooltip_scene: PackedScene
var tooltip: Control


func _ready() -> void:
	GlobalsUi.gui = self

	tooltip = tooltip_scene.instantiate()
	add_child(tooltip)
	tooltip.visible = false



func show_tooltip(show: bool, text: String, position: Vector2):
	tooltip.visible = show

	if not show:
		return

	tooltip.position = position
	tooltip.get_node("Label").text = text
