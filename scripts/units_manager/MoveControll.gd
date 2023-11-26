class_name MoveControll
extends Node

const CONFIRM_CLICK_DISTANCE_PX := 10

@export var object_mover: ObjectMover
@export var line2d_manager: Line2dManager

var move_target_pos: Vector2
var is_second_click: bool = false


func try_to_move(unit_object: UnitObject, mouse_pos: Vector2):
	if _cant_move():
		return

	var world_pos: Vector2 = GlobalUtils.screen_pos_to_world_pos(mouse_pos)

	var is_second_click_to_same_point = is_second_click and move_target_pos.distance_to(world_pos) < CONFIRM_CLICK_DISTANCE_PX
	if is_second_click_to_same_point:
		_move_unit(unit_object, move_target_pos)
	else:
		_show_future_path(unit_object, world_pos)


func _cant_move() -> bool:
	return object_mover.is_object_moving()


func _move_unit(unit_object: UnitObject, world_pos: Vector2):
	object_mover.move_object_to_pos(unit_object, world_pos)
	is_second_click = false
	line2d_manager.clear_path()


func _show_future_path(unit_object: UnitObject, world_pos: Vector2):
	var path := GlobalUtils.find_path(unit_object.position, world_pos)
	_draw_path(path)

	move_target_pos = world_pos
	is_second_click = true


func _draw_path(path: PackedVector2Array):
	var path_array: Array[Vector2]
	path_array.assign(Array(path))
	line2d_manager.clear_path()
	line2d_manager.draw_path_without_offset(path_array, false)
