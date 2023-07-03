class_name GUI
extends Control


@export var tooltip_scene: PackedScene
@export var setup_tooltip_scene: PackedScene
@export var flying_tooltip_scene: PackedScene
@export var message_scene: PackedScene
@export var path_message_spawn: NodePath

@onready var battle_ui = $AlwaysUI/BattleUI
@onready var unit_setup_ui = $AlwaysUI/UnitSetupUI


var tooltip: Control
var setup_tooltip: Control
var flying_tooltip: Control
var message: Control
var default_pos_message: Vector2

var tween: Tween
var flying_tooltip_tween: Tween


func _ready() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)

	GlobalsUi.gui = self

	tooltip = tooltip_scene.instantiate()
	tooltip.visible = false
	add_child(tooltip)

	setup_tooltip = setup_tooltip_scene.instantiate()
	setup_tooltip.visible = false
	$AlwaysUI.add_child(setup_tooltip)

	flying_tooltip = flying_tooltip_scene.instantiate()
	flying_tooltip.visible = false
	add_child(flying_tooltip)

	message = message_scene.instantiate()
	message.visible = false
	get_node(path_message_spawn).add_child(message)
	default_pos_message = message.position


func init():
	battle_ui.init()


func init_unit_setup(game_progress: GameProgress, callback):
	unit_setup_ui.init(game_progress, callback)


func _on_unit_died(unit_id: int, killer_id: int):
	show_tooltip(false)


func show_tooltip(show: bool, text: String = "", position: Vector2 = Vector2.ZERO):
	tooltip.visible = show

	if not show:
		return

	tooltip.position = position
	tooltip.scale = Vector2.ONE / get_viewport().get_camera_2d().zoom
	tooltip.get_node("Label").text = text


func show_flying_tooltip(text: String, position: Vector2 = Vector2.ZERO):
	if flying_tooltip_tween:
		flying_tooltip_tween.kill()
		hide_flying_tooltip()

	flying_tooltip_tween = create_tween()
	flying_tooltip_tween.tween_property(flying_tooltip, "position", position + Vector2(0, -20), 1.0).from(position).set_trans(Tween.TRANS_QUAD)
	flying_tooltip_tween.tween_property(flying_tooltip, "modulate", Color(Color.WHITE, 0.0), 0.5)
	flying_tooltip_tween.tween_callback(hide_flying_tooltip)

	flying_tooltip.visible = true
	flying_tooltip.get_node("Label").text = text


func hide_flying_tooltip():
	flying_tooltip.visible = false
	flying_tooltip.modulate.a = 1.0


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
