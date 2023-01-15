class_name GUI
extends Control


@export var tooltip_scene: PackedScene
@export var message_scene: PackedScene
@export var path_message_spawn: NodePath

@onready var battle_ui = get_node("BattleUI")
@onready var selected_unit_info: UiSelectedUnitInfo = get_node("%SelectedUnitInfo")

var tooltip: Control
var message: Control
var default_pos_message: Vector2

var tween: Tween


func _ready() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)

	GlobalsUi.gui = self

	tooltip = tooltip_scene.instantiate()
	tooltip.visible = false
	add_child(tooltip)

	message = message_scene.instantiate()
	message.visible = false
	get_node(path_message_spawn).add_child(message)
	default_pos_message = message.position


func init():
	battle_ui.init()
	selected_unit_info.init()


func _on_unit_died(unit_id: int, killer_id: int):
	show_tooltip(false)


func show_tooltip(show: bool, text: String = "", position: Vector2 = Vector2.ZERO):
	tooltip.visible = show

	if not show:
		return

	tooltip.position = position
	tooltip.scale = Vector2.ONE / get_viewport().get_camera_2d().zoom
	tooltip.get_node("Label").text = text


func show_message(text: String):
	if tween:
		tween.kill()
		hide_message()

	tween = create_tween()
	tween.tween_property(message, "position", default_pos_message + Vector2(0, -50), 1.0).from(default_pos_message + Vector2(0, 50)).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(message, "modulate", Color(Color.WHITE, 0.0), 0.5)
	tween.tween_callback(hide_message)

	message.visible = true
	message.get_node("Label").text = text


func hide_message():
	message.visible = false
	message.modulate.a = 1.0
