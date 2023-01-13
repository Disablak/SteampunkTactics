class_name CameraController
extends Node2D


const PIXEL_TRASH_HOLD = 10

@export var focus_time = 0.2
@export var drag_sensitive = 0.4
@export_node_path var bounds_path

var tween_move: Tween

var bounds_min: Vector2
var bounds_max: Vector2

var dict_id_and_prev_pos = {}

func camera_is_moving() -> bool:
	return tween_move != null and tween_move.is_running()


func _ready() -> void:
	var bounds: Node2D = get_node(bounds_path)
	var camera_bound_rect = Rect2(bounds.position, bounds.scale * Globals.CELL_SIZE)
	_calc_bounds(camera_bound_rect)

	GlobalBus.on_unit_changed_control.connect(focus_camera)


func center_camera_between_two_units(unit_first: Unit, unit_second: Unit) -> Signal:
	var vector := unit_second.unit_object.position - unit_first.unit_object.position
	var distance := unit_second.unit_object.position.distance_to(unit_first.unit_object.position)
	var center_pos := (vector.normalized() * (distance / 2)) + unit_first.unit_object.position

	var time_tween = 0.5 if center_pos.distance_to(position) > PIXEL_TRASH_HOLD else 0.0

	return move_camera(center_pos, time_tween)


func move_camera(target_pos: Vector2, time: float) -> Signal:
	target_pos = _clamp_pos_in_bounds(target_pos)

	tween_move = create_tween()
	tween_move.set_trans(Tween.TRANS_SINE)
	tween_move.tween_property(
		self,
		"position",
		target_pos,
		time
	)

	return tween_move.finished


func focus_camera(unit_id, instantly) -> Signal:
	var target_pos: Vector2

	if dict_id_and_prev_pos.has(unit_id):
		target_pos = dict_id_and_prev_pos[unit_id]
	else:
		dict_id_and_prev_pos[TurnManager.get_prev_unit_id()] = position
		var unit: Unit = GlobalUnits.units[unit_id]
		var unit_pos = unit.unit_object.position
		target_pos = _clamp_pos_in_bounds(unit_pos)

	return move_camera(target_pos, 0.0 if instantly else focus_time)


func is_camera_moving() -> bool:
	return tween_move != null and tween_move.is_running()


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


