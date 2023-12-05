class_name MoveControll
extends Node

const CONFIRM_CLICK_DISTANCE_PX := 2

@export var object_mover: ObjectMover
@export var line2d_manager: Line2dManager

var _move_target_pos: Vector2
var _is_second_click: bool = false


func try_to_move(unit: Unit, mouse_pos: Vector2):
	var world_pos: Vector2 = GlobalUtils.screen_pos_to_world_pos(mouse_pos)
	var path := GlobalUtils.find_path(unit.unit_object.position, world_pos)
	var path_distance: float = Globals.get_total_distance(path)
	var move_price: int = path_distance / 100 * unit.unit_data.move_speed

	if not _can_move(move_price):
		return

	var is_second_click_to_same_point = _is_second_click and _move_target_pos.distance_to(world_pos) < CONFIRM_CLICK_DISTANCE_PX
	if is_second_click_to_same_point:
		TurnManager.spend_time_points(move_price)
		_move_unit(unit.unit_object, _move_target_pos)
	else:
		TurnManager.show_hint_spend_points(move_price)
		_show_future_path(unit.unit_object, world_pos)


func deselect_move():
	_is_second_click = false
	line2d_manager.clear_path()
	TurnManager.show_hint_spend_points(0)


func _can_move(move_price: int) -> bool:
	if object_mover.is_object_moving():
		return false

	if not TurnManager.enough_time_points_for_start_move():
		return false

	if not TurnManager.can_spend_time_points(move_price):
		return false

	return true


func _move_unit(unit_object: UnitObject, world_pos: Vector2):
	object_mover.move_object_to_pos(unit_object, world_pos)
	deselect_move()


func _show_future_path(unit_object: UnitObject, world_pos: Vector2):
	var path := GlobalUtils.find_path(unit_object.position, world_pos)
	_draw_path(path)

	_move_target_pos = world_pos
	_is_second_click = true


func _draw_path(path: PackedVector2Array):
	var path_array: Array[Vector2]
	path_array.assign(Array(path))
	line2d_manager.clear_path()
	line2d_manager.draw_path_without_offset(path_array, false)
