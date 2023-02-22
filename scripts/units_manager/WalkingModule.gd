class_name WalkingModule
extends Node2D


signal on_finished_move()

const ROTATION_SPEED = 10
const MOVING_SPEED = 100

var cur_unit_object: UnitObject
var cur_unit_data: UnitData

var tween_move: Tween
var pathfinding: Pathfinding
var callable_finish_move: Callable

var prev_unit_pos: Vector2i
var prev_max_distance: int
var cached_walking_cells: Array[Vector2i]


func set_data(pathfinding: Pathfinding, callable_finish_move: Callable):
	self.pathfinding = pathfinding
	self.callable_finish_move = callable_finish_move


func set_cur_unit(unit: Unit):
	cur_unit_object = unit.unit_object
	cur_unit_data = unit.unit_data


func is_unit_moving() -> bool:
	return tween_move != null and tween_move.is_running()


func can_move_here(grid_pos: Vector2i) -> bool:
	return cached_walking_cells.has(grid_pos)


func move_unit(path: Array[Vector2i]):
	var price_time_points = get_move_price(path)
	if not TurnManager.can_spend_time_points(price_time_points):
		return

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.WALKING, price_time_points)
	_move_via_points(path)


func get_move_price(path: Array[Vector2i]) -> int:
	var distance = Globals.get_total_distance(path)
	var price_time_points = cur_unit_data.get_move_price(distance)
	return price_time_points


func draw_walking_cells(): # todo if unit change time points without moving, it will be a bug
	update_walking_cells()
	pathfinding.draw_walking_cells(cached_walking_cells)


func update_walking_cells(force_update: bool = false):
	var unit_pos := cur_unit_object.position
	var unit_grid_pos := Globals.convert_to_grid_pos(unit_pos)
	var max_move_distance : int = int(TurnManager.cur_time_points / cur_unit_data.unit_settings.walk_speed) + 1

	if force_update or unit_grid_pos != prev_unit_pos or prev_max_distance != max_move_distance:
		prev_unit_pos = unit_grid_pos
		prev_max_distance = max_move_distance

		var path_walking_cells := pathfinding.get_walkable_cells(unit_grid_pos, max_move_distance)
		var team_visibility_cells := pathfinding.fog_of_war.get_cur_team_visibility()
		var intersected_cells: Array[Vector2i]
		intersected_cells.assign(MyMath.arr_intersect(path_walking_cells, team_visibility_cells))
		cached_walking_cells = path_walking_cells if cur_unit_data.is_enemy else intersected_cells


func clear_walking_cells():
	pathfinding.clear_walking_cells()


func _move_via_points(points: Array[Vector2i]):
	var converted_points := Globals.convert_grid_poses_to_cell_poses(points)
	var cur_target_id = 0

	for point in converted_points:
		if cur_target_id == converted_points.size() - 1:
			_on_unit_finished_move()
			on_finished_move.emit()
			return

		var start_point := converted_points[cur_target_id]
		var finish_point := converted_points[cur_target_id + 1]
		var time_move = start_point.distance_to(finish_point) / MOVING_SPEED

		var move_direction: int = rad_to_deg(start_point.angle_to_point(finish_point))
		cur_unit_data.update_view_direction(move_direction)

		tween_move = get_tree().create_tween()
		tween_move.tween_property(
			cur_unit_object,
			"position",
			finish_point,
			time_move
		).from(start_point)

		cur_target_id += 1

		await tween_move.finished

		GlobalBus.on_unit_moved_to_another_cell.emit(cur_unit_data.unit_id, finish_point)


func _on_unit_finished_move():
	#cur_unit_object.unit_animator.play_anim(Globals.AnimationType.IDLE)
	#draw_walking_cells()
	callable_finish_move.call()
