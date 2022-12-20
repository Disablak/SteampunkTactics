extends Node2D


@export var focus_time = 0.2
@export var drag_sensitive = 0.4
@export_node_path var bounds_path

signal on_focused

var tween_move: Tween

var bounds_min: Vector2
var bounds_max: Vector2



func _ready() -> void:
	var bounds: Node2D = get_node(bounds_path)
	var camera_bound_rect = Rect2(bounds.position, bounds.scale * Globals.CELL_SIZE)
	_calc_bounds(camera_bound_rect)

	GlobalBus.on_unit_changed_control.connect(focus_camera)
	focus_camera(GlobalUnits.cur_unit_id, true)


func focus_camera(unit_id, instantly):
	var unit_pos = GlobalUnits.units[unit_id].unit_object.position
	var target_pos: Vector2 = _clamp_pos_in_bounds(unit_pos)

	if instantly:
		position = target_pos
		emit_on_focused()
		return

	tween_move = create_tween()
	tween_move.tween_callback(emit_on_focused)
	tween_move.set_trans(Tween.TRANS_SINE)
	tween_move.tween_property(
		self,
		"position",
		target_pos,
		focus_time
	)


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


