class_name CameraController
extends Node2D


const PIXEL_TRASH_HOLD = 3

@export var camera: Camera2D
@export var focus_time = 0.2
@export var drag_sensitive = 0.4
@export var save_prev_pos = true
@export var helper_size_of_full := 0.5
@export var map_camera_offset_cells = 8

var map_size: Vector2
var tween_move: Tween

var sensetive: float
var bounds_min: Vector2
var bounds_max: Vector2
var viewport_helper_size: Vector2

var dict_id_and_prev_pos = {}

func camera_is_moving() -> bool:
	return tween_move != null and tween_move.is_running()


func _ready() -> void:
	GlobalBus.on_changed_level.connect(_on_changed_level)


func center_camera_between_two_units(unit_first: Unit, unit_second: Unit):
	var vector := unit_second.unit_object.position - unit_first.unit_object.position
	var distance := unit_second.unit_object.position.distance_to(unit_first.unit_object.position)
	var center_pos := (vector.normalized() * (distance / 2)) + unit_first.unit_object.position

	var time_tween = 0.5 if center_pos.distance_to(position) > PIXEL_TRASH_HOLD else 0.0

	await move_camera(center_pos, time_tween)


func move_camera(target_pos: Vector2, time: float):
	target_pos = _clamp_pos_in_bounds(target_pos)

	tween_move = create_tween()
	tween_move.set_trans(Tween.TRANS_SINE)
	tween_move.tween_property(
		self,
		"position",
		target_pos,
		time
	)

	await tween_move.finished


func is_camera_moving() -> bool:
	return tween_move != null and tween_move.is_running()


func drag(vector_move: Vector2) -> void:
	var new_pos = camera.position + vector_move * drag_sensitive
	#camera.position = new_pos
	camera.position = _clamp_pos_in_bounds(new_pos)


func try_to_move_in_helper_view(pos: Vector2):
	if not GlobalMap.can_show_cur_unit():
		return

	if not is_pos_in_view_helper(pos):
		var target_pos = get_clamped_pos_in_helper(pos)
		move_camera(target_pos, focus_time)


func is_pos_in_view_helper(pos: Vector2) -> bool:
	var rect: Rect2 = Rect2(position - viewport_helper_size / 2, viewport_helper_size)
	return rect.has_point(pos)


func get_clamped_pos_in_helper(pos: Vector2) -> Vector2:
	return Vector2(clampf(pos.x, position.x - viewport_helper_size.x, position.x + viewport_helper_size.x), clampf(pos.y, position.y - viewport_helper_size.y, position.y + viewport_helper_size.y))


func _on_changed_level(lvl_id):
	var node_camera_borders: Sprite2D = get_tree().get_first_node_in_group("camera_bounds") as Sprite2D
	var size_px = node_camera_borders.scale * node_camera_borders.texture.get_size()
	_calc_bounds(node_camera_borders.position, size_px)


func _calc_bounds(pos: Vector2, size_px: Vector2):
	var camera_bound_rect := Rect2(pos, size_px)
	var zoom := get_viewport().get_camera_2d().zoom
	sensetive = drag_sensitive / zoom.x

	var viewport_size := get_viewport_rect().size / zoom

	bounds_min.x = camera_bound_rect.position.x
	bounds_min.y = camera_bound_rect.position.y
	bounds_max.x = camera_bound_rect.end.x - viewport_size.x
	bounds_max.y = camera_bound_rect.end.y - viewport_size.y

	viewport_helper_size = (viewport_size / zoom) * helper_size_of_full


func _clamp_pos_in_bounds(pos: Vector2) -> Vector2:
	return Vector2(clampf(pos.x, bounds_min.x, bounds_max.x), clampf(pos.y, bounds_min.y, bounds_max.y))


func _on_input_system_on_drag(dir: Vector2) -> void:
	drag(dir)
