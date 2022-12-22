class_name GUI
extends Control


@export var tooltip_scene: PackedScene
var tooltip: Control


func _ready() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)

	GlobalsUi.gui = self

	tooltip = tooltip_scene.instantiate()
	add_child(tooltip)
	tooltip.visible = false


func _gui_input(event: InputEvent) -> void:
	pass


func _on_unit_died(unit_id: int, killer_id: int):
	show_tooltip(false)


func show_tooltip(show: bool, text: String = "", position: Vector2 = Vector2.ZERO):
	tooltip.visible = show

	if not show:
		return

	tooltip.position = position
	tooltip.scale = Vector2.ONE / get_viewport().get_camera_2d().zoom
	tooltip.get_node("Label").text = text
