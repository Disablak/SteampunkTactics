class_name CameraController
extends Node2D


const PIXEL_TRASH_HOLD = 3

@export var focus_time = 0.2
@export var drag_sensitive = 0.4
@export var save_prev_pos = true
@export var helper_size_of_full := 0.5
@export_node_path var bounds_path

var tween_move: Tween

var sensetive: float
var bounds_min: Vector2
var bounds_max: Vector2
var viewport_helper_size: Vector2

var dict_id_and_prev_pos = {}

func camera_is_moving() -> bool:
	return tween_move != null and tween_move.is_running()


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(focus_camera)
	GlobalBus.on_change_camera_zoom.connect(_on_camera_zoom_changed)


func init():
	_calc_bounds()

	var first_unit: Unit = GlobalUnits.get_cur_unit()
	move_camera(first_unit.unit_object.position, 0.0)


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

	if save_prev_pos and dict_id_and_prev_pos.has(unit_id):
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
	var new_pos = position + vector_move * sensetive
	position = _clamp_pos_in_bounds(new_pos)


func try_to_move_in_helper_view(pos: Vector2):
	if not is_pos_in_view_helper(pos):
		var target_pos = get_clamped_pos_in_helper(pos)
		move_camera(target_pos, focus_time)


func is_pos_in_view_helper(pos: Vector2) -> bool:
	var rect: Rect2 = Rect2(position - viewport_helper_size / 2, viewport_helper_size)
	return rect.has_point(pos)


func get_clamped_pos_in_helper(pos: Vector2) -> Vector2:
	return Vector2(clampf(pos.x, position.x - viewport_helper_size.x, position.x + viewport_helper_size.x), clampf(pos.y, position.y - viewport_helper_size.y, position.y + viewport_helper_size.y))


func _calc_bounds():
	var bounds: Node2D = get_node(bounds_path)
	var camera_bound_rect := Rect2(bounds.position, bounds.scale * Globals.CELL_SIZE)

	var zoom := get_viewport().get_camera_2d().zoom
	sensetive = drag_sensitive / zoom.x

	var half_bound_size := camera_bound_rect.size / 2
	var viewport_height := get_viewport_rect().size.y
	var square_viewport_size := Vector2(viewport_height, viewport_height)
	var half_camera_size := square_viewport_size / zoom / 2

	bounds_min.x = -half_bound_size.x + camera_bound_rect.position.x + half_camera_size.x
	bounds_min.y = -half_bound_size.y + camera_bound_rect.position.y + half_camera_size.y
	bounds_max.x =  half_bound_size.x + camera_bound_rect.position.x - half_camera_size.x
	bounds_max.y =  half_bound_size.y + camera_bound_rect.position.y - half_camera_size.y

	viewport_helper_size = (square_viewport_size / zoom) * helper_size_of_full


func _clamp_pos_in_bounds(pos: Vector2) -> Vector2:
	return Vector2(clampf(pos.x, bounds_min.x, bounds_max.x), clampf(pos.y, bounds_min.y, bounds_max.y))


func _on_camera_zoom_changed(zoom: float):
	get_viewport().get_camera_2d().zoom = Vector2(zoom, zoom)
	_calc_bounds()

