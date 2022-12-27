class_name CameraController
extends Node2D


@export var focus_time = 0.2
@export var drag_sensitive = 0.4
@export_node_path var bounds_path

signal on_focused

var tween_move: Tween

var bounds_min: Vector2
var bounds_max: Vector2

var prev_player_camera_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	var bounds: Node2D = get_node(bounds_path)
	var camera_bound_rect = Rect2(bounds.position, bounds.scale * Globals.CELL_SIZE)
	_calc_bounds(camera_bound_rect)

	GlobalBus.on_unit_changed_control.connect(focus_camera)


func focus_camera(unit_id, instantly):
	var target_pos: Vector2

	var unit : Unit = GlobalUnits.units[unit_id]
	if unit.unit_data.unit_settings.is_enemy or prev_player_camera_pos == Vector2.ZERO:
		prev_player_camera_pos = position
		var unit_pos = unit.unit_object.position
		target_pos = _clamp_pos_in_bounds(unit_pos)
	else:
		target_pos = prev_player_camera_pos

	if instantly:
		position = target_pos
		emit_on_focused()
		return

	tween_move = create_tween()
	tween_move.set_trans(Tween.TRANS_SINE)
	tween_move.tween_property(
		self,
		"position",
		target_pos,
		focus_time
	)
	tween_move.tween_callback(emit_on_focused)


func is_camera_moving() -> bool:
	return tween_move != null and tween_move.is_running()


func emit_on_focused():
	on_focused.emit()


func drag(vector_move: Vector2) -> void:
	var new_pos = position + vector_move * drag_sensitive
	position = _clamp_pos_in_bounds(new_pos)


func _calc_bounds(camera_bound_rect: Rect2):
	var half_bound_size := camera_bound_rect.size / 2
	var half_camera_size := get_viewport_rect().size / get_viewport().get_camera_2d().zoom / 2

	bounds_min.x = -half_bound_size.x + camera_bound_rect.position.x + half_camera_size.x
	bounds_min.y = -half_bound_size.y + camera_bound_rect.position.y + half_camera_size.y
	bounds_max.x =  half_bound_size.x + camera_bound_rect.position.x - half_camera_size.x
	bounds_max.y =  half_bound_size.y + camera_bound_rect.position.y - half_camera_size.y


func _clamp_pos_in_bounds(pos: Vector2) -> Vector2:
	return Vector2(clampf(pos.x, bounds_min.x, bounds_max.x), clampf(pos.y, bounds_min.y, bounds_max.y))


