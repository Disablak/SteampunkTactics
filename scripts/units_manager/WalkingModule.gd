class_name WalkingModule
extends Node2D


const ROTATION_SPEED = 10
const MOVING_SPEED = 3

var cur_unit_object: UnitObject
var cur_unit_data: UnitData

var tween_move: Tween
var pathfinding: Pathfinding
var callable_finish_move: Callable


func set_data(pathfinding: Pathfinding, callable_finish_move: Callable):
	self.pathfinding = pathfinding
	self.callable_finish_move = callable_finish_move


func set_cur_unit(unit: Unit):
	cur_unit_object = unit.unit_object
	cur_unit_data = unit.unit_data
	
	draw_walking_cells()


func is_unit_moving() -> bool:
	return tween_move != null and tween_move.is_running()


func try_move(raycast_result, input_event: InputEventMouseButton, cur_unit_action) -> bool:
	if not (input_event.pressed and input_event.button_index == 2 and raycast_result.collider.is_in_group("pathable")):
		return false
	
	if raycast_result.position == Vector3.ZERO:
		return false
		
	if cur_unit_action != Globals.UnitAction.WALK:
		return false
		
	move_unit(raycast_result.position)
	return true


func move_unit(path: PackedVector2Array):
	var price_time_points = get_move_price(path)
	if not TurnManager.can_spend_time_points(price_time_points):
		return
	
	TurnManager.spend_time_points(TurnManager.TypeSpendAction.WALKING, price_time_points)
	_move_via_points(path)


func get_move_price_to_pos(pos : Vector2) -> int:
	var path : PackedVector2Array = cur_unit_object.get_move_path(pos)
	var price_time_points = get_move_price(path)
	return price_time_points


func get_move_price(path : PackedVector2Array) -> int:
	var distance = Globals.get_total_distance(path)
	var price_time_points = cur_unit_data.get_move_price(distance)
	return price_time_points


func draw_walking_cells():
	var unit_pos := Globals.convert_to_tile_pos(cur_unit_object.position)
	var max_move_distance : int = int(TurnManager.cur_time_points / cur_unit_data.unit_settings.walk_speed) + 1
	print(max_move_distance)
	var walking_cells := pathfinding.get_walkable_cells(unit_pos, max_move_distance)
	pathfinding.draw_walking_cells(walking_cells)


func _move_via_points(points: PackedVector2Array):
	var cur_target_id = 0
	
	for point in points:
		if cur_target_id == points.size() - 1:
			_on_unit_finished_move()
			return
		
		var start_point = points[cur_target_id]
		var finish_point = points[cur_target_id + 1]
		var time_move = start_point.distance_to(finish_point) / 500
		
		tween_move = get_tree().create_tween()
		tween_move.tween_property(
			cur_unit_object,
			"position",
			finish_point,
			time_move
		).from(start_point)
		
		cur_target_id += 1
		await tween_move.finished 


func _on_unit_finished_move():
	#cur_unit_object.unit_animator.play_anim(Globals.AnimationType.IDLE)
	draw_walking_cells()
	callable_finish_move.call()
