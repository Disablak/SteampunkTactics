class_name AiWorld
extends Node2D


var cached_walking_cell_target: Vector2i
var cacned_walking_cell_price: int

var units_manager: UnitsManager
var walking: WalkingModule
var brain_ai: BrainAI


var _cur_unit: Unit:
	get: return GlobalUnits.get_cur_unit()


func _ready() -> void:
	GlobalMap.ai_world = self


func init(units_manager: UnitsManager):
	self.units_manager = units_manager
	self.brain_ai = units_manager.brain_ai
	self.walking = units_manager.walking


func _get_visible_covers() -> Array[Vector2i]:
	var visible_cells := _cur_unit.unit_data.visibility_data.visible_points
	var visible_covers := units_manager.pathfinding.get_covers_in_points(visible_cells)
	return visible_covers


func get_visible_enemies() -> Array[Unit]:
	var visible_cells := _cur_unit.unit_data.visibility_data.visible_points
	var all_enemies := GlobalUnits.get_units(!_cur_unit.unit_data.is_enemy)
	var result: Array[Unit]
	for enemy in all_enemies: # lambda not work!
		if visible_cells.has(enemy.unit_object.grid_pos):
			result.append(enemy)

	_cur_unit.unit_data.ai_settings.visible_enemies = result
	return result


func _get_shortest_path_to_target(targets: Array[Vector2i]) -> PathData:
	var path_data: PathData = PathData.new()

	for point in targets: # lambda not work!
		if units_manager.pathfinding.has_path(_cur_unit.unit_object.grid_pos, point, true):
			var path_d := units_manager.pathfinding.get_path_to_point(_cur_unit.unit_object.grid_pos, point, true)
			if path_data.is_empty or path_data.path.size() > path_d.path.size():
				path_data = path_d
				path_data.target_point = point

	return path_data


func _get_cover_that_cover_me_from_any_enemy() -> PathData:
	var covers := _get_visible_covers()
	var enemies := get_visible_enemies()
	var path_data: PathData = PathData.new()

	for cover_pos in covers:  # lambda not work!
		for enemy in enemies:
			var intersected_obs := units_manager.raycaster.make_ray_get_obstacles(Globals.convert_to_cell_pos(cover_pos), Globals.convert_to_cell_pos(enemy.unit_object.grid_pos))
			for cell_obj in intersected_obs:
				if cell_obj.cell_type != CellObject.CellType.COVER:
					continue

				var path_to_cover = units_manager.pathfinding.get_path_to_point(_cur_unit.unit_object.grid_pos, cover_pos).path
				if path_data.path.size() == 0 or path_data.path.size() > path_to_cover.size():
					path_data.path = path_to_cover
					path_data.target_point = cover_pos

	return path_data


func get_cover_that_help() -> PathData:
	var path_data_cover = _get_cover_that_cover_me_from_any_enemy()
	_cur_unit.unit_data.ai_settings.cover_path_data = path_data_cover
	return path_data_cover


func find_random_cell_and_get_price_walk() -> int:
	walking.update_walking_cells()

	var walking_cells: Array[Vector2i] = _get_walking_cells()
	if walking_cells.size() != 0:
		cached_walking_cell_target = walking_cells.pick_random()
		var path := units_manager.get_path_to_cell(cached_walking_cell_target)
		var price_move := walking.get_move_price(path)
		cacned_walking_cell_price = price_move
	else:
		cached_walking_cell_target = Vector2i.ZERO
		cacned_walking_cell_price = 999

	return cacned_walking_cell_price


func _get_walking_cells() -> Array[Vector2i]:
	if _cur_unit.unit_data.ai_settings.walking_zone_cells.size() == 0:
		return walking.cached_walking_cells
	else:
		return MyMath.arr_intersect(walking.cached_walking_cells, _cur_unit.unit_data.ai_settings.walking_zone_cells)


func _get_path_to_any_points(points: Array[Vector2i]) -> Array[Vector2i]:
	points.shuffle()
	for point in points:
		if units_manager.pathfinding.has_path(_cur_unit.unit_object.grid_pos, point, true):
			var path = units_manager.pathfinding.get_path_to_point(_cur_unit.unit_object.grid_pos, point, true).path
			return path

	return []


func is_unit_reched_patrul_zone():
	var zone_cells := _cur_unit.unit_data.ai_settings.get_cur_target_patrul_zone_points()
	return zone_cells.has(_cur_unit.unit_object.grid_pos)


func is_unit_in_cover() -> bool:
	var in_cover := units_manager.pathfinding.is_point_has_cover(_cur_unit.unit_object.grid_pos)
	return in_cover


func find_path_to_patrul_zone() -> Vector2i:
	if is_unit_reched_patrul_zone():
		_cur_unit.unit_data.ai_settings.patrul_next_zone()

	var path := _get_path_to_any_points(_cur_unit.unit_data.ai_settings.get_cur_target_patrul_zone_points())
	if path.size() == 0:
		return Vector2i.ZERO

	var max_cells := _get_max_cells_to_walk()
	var max_reached_point := path[min(max_cells, path.size() - 1)]

	_cur_unit.unit_data.ai_settings.walk_pos_to_patrul_zone = max_reached_point
	return max_reached_point


func find_path_to_near_enemy() -> PathData:
	var visible_enemy = get_visible_enemies()
	var enemy_points: Array[Vector2i] = []
	for enemy in visible_enemy: # todo need select!
		enemy_points.append(enemy.unit_object.grid_pos)

	var enemy_path_data := _get_shortest_path_to_target(enemy_points)
	if enemy_path_data.is_empty:
		printerr("not found path to unit")
		return null

	var points_around_unit := units_manager.pathfinding.get_grid_poses_by_pattern(enemy_path_data.target_point, Globals.CELL_AREA_FOUR_DIR)
	var points_without_obs := _get_ray_pos_that_not_collide_obs(enemy_path_data.target_point, points_around_unit)
	var enemy_side_path_data := _get_shortest_path_to_target(points_without_obs)
	enemy_side_path_data.unit_id = units_manager.pathfinding.get_unit_on_cell(enemy_path_data.target_point).id

	if enemy_side_path_data.is_empty:
		printerr("not found path to unit")
		return null

	_cur_unit.unit_data.ai_settings.shortest_path_to_enemy = enemy_side_path_data
	return enemy_side_path_data


func _get_ray_pos_that_not_collide_obs(ray_start_pos: Vector2i, target_points: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i]
	for point in target_points:
		var intersected_obs := units_manager.raycaster.make_ray_get_obstacles(Globals.convert_to_cell_pos(ray_start_pos), Globals.convert_to_cell_pos(point))
		if intersected_obs.size() == 0:
			result.append(point)

	return result


func is_any_enemy_near_unit() -> bool:
	var points_around_unit := units_manager.pathfinding.get_grid_poses_by_pattern(_cur_unit.unit_object.grid_pos, Globals.CELL_AREA_FOUR_DIR)

	for grid_pos in points_around_unit:
		var unit: Unit = units_manager.pathfinding.get_unit_on_cell(grid_pos)
		if unit != null:
			if GlobalMap.raycaster.make_ray_check_no_obstacle(_cur_unit.unit_object.position, unit.unit_object.position):
				_cur_unit.unit_data.ai_settings.enemy_stand_near = unit.id
				return true

	_cur_unit.unit_data.ai_settings.enemy_stand_near = -1
	return false


func is_attention_dir_exist() -> bool:
	return _cur_unit.unit_data.attention_direction != -1


func is_attention_pos_exist() -> bool:
	return _cur_unit.unit_data.visibility_data.enemies_saw.size() > 0


func is_attention_pos_enemy_exist() -> bool:
	return _cur_unit.unit_data.visibility_data.enemy_attention_grid_pos != Vector2i.ZERO


func _get_max_cells_to_walk() -> int:
	return floori(float(TurnManager.cur_time_points) / _cur_unit.unit_data.unit_settings.walk_speed)


func get_price_move_to_enemy() -> int:
	return get_price_move_path(_cur_unit.unit_data.ai_settings.shortest_path_to_enemy)


func get_price_move_to_cover() -> int:
	return get_price_move_path(_cur_unit.unit_data.ai_settings.cover_path_data)


func get_price_move_path(path_data: PathData) -> int:
	var count_cells = path_data.path.size() - 1
	var doors_open_price = path_data.doors.size() * Globals.TP_TO_OPEN_DOOR
	return count_cells * _cur_unit.unit_data.unit_settings.walk_speed + doors_open_price


func get_max_price_move():
	if not TurnManager.can_spend_time_points(_cur_unit.unit_data.unit_settings.walk_speed):
		return 999

	return _get_max_cells_to_walk() * _cur_unit.unit_data.unit_settings.walk_speed


func _get_max_point_to_walk(path: Array[Vector2i]) -> Vector2i:
	var available_cells_to_walk := _get_max_cells_to_walk()
	var idx = min(available_cells_to_walk, path.size() - 1)
	return path[idx]


func try_rotate_to_cover(point: Vector2i):
	if point != _cur_unit.unit_data.ai_settings.cover_path_data.path[-1]:
		return

	var cur_unit_pos := _cur_unit.unit_object.grid_pos
	var cell := units_manager.pathfinding.get_cell_by_pos(cur_unit_pos)
	if cell.cell_type != CellObject.CellType.COVER:
		printerr("not cover!")

	var angle: int = cell.comp_wall.get_cover_angle(cur_unit_pos)
	_cur_unit.unit_data.update_view_direction(angle, true)


func walk_to_attention_pos():
	await ultimate_walk(_cur_unit.unit_data.visibility_data.enemy_attention_grid_pos)

	var see_enemy: bool = _cur_unit.unit_data.visibility_data.is_see_enemy()
	var attention_pos_reached := _cur_unit.unit_object.grid_pos == _cur_unit.unit_data.visibility_data.enemy_attention_grid_pos

	if see_enemy or attention_pos_reached:
		_cur_unit.unit_data.visibility_data.enemy_attention_grid_pos = Vector2i.ZERO

	if not see_enemy and attention_pos_reached:
		await look_around()

	brain_ai.decide_best_action_and_execute()


func walk_to_cover():
	var point := _get_max_point_to_walk(_cur_unit.unit_data.ai_settings.cover_path_data.path)
	await ultimate_walk(point)
	try_rotate_to_cover(point)
	brain_ai.decide_best_action_and_execute()


func walk_to_patrul_zone():
	await ultimate_walk(_cur_unit.unit_data.ai_settings.walk_pos_to_patrul_zone)
	brain_ai.decide_best_action_and_execute()


func walk_to_near_enemy():
	var path_to_enemy = _cur_unit.unit_data.ai_settings.shortest_path_to_enemy
	var point := _get_max_point_to_walk(_cur_unit.unit_data.ai_settings.shortest_path_to_enemy.path)

	await ultimate_walk(point)
	brain_ai.decide_best_action_and_execute()


func walk_to_rand_cell():
	await ultimate_walk(cached_walking_cell_target)
	brain_ai.decide_best_action_and_execute()


func move_and_open_door(path_data: PathData):
	var first_door: CellObject = path_data.doors.values().front()
	var door_pos: Vector2i = path_data.doors.keys().front()
	var door_idx := path_data.path.find(door_pos)
	var path_to_door := path_data.path.slice(0, door_idx + 1)

	await move(path_to_door)
	await interact_door(first_door)


func ultimate_walk(target_pos: Vector2i):
	var path_data := units_manager.pathfinding.get_path_to_point(_cur_unit.unit_object.grid_pos, target_pos, true)
	if path_data.is_empty:
		return

	if path_data.doors.is_empty():
		await move(path_data.path)
	else:
		await move_and_open_door(path_data)


func move(path: Array[Vector2i]):
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	if _get_max_cells_to_walk() == 0:
		return

	if path.size() <= 1:
		return

	var max_path_point := _get_max_point_to_walk(path)
	units_manager.walking.draw_walking_cells()
	await make_delay(0.5)

	units_manager.change_unit_action(UnitData.Abilities.WALK)
	units_manager.try_move_unit_to_cell(max_path_point)
	await walking.on_finished_move
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)
	units_manager.change_unit_action(UnitData.Abilities.NONE)
	await make_delay(0.5)


func interact_door(door: CellObject):
	units_manager.interact_with_door(door)
	await make_delay(0.5)


func rotate_to_attention():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	if _cur_unit.unit_data.attention_direction != -1:
		_cur_unit.unit_data.rotate_to_attention_dir()
		Globals.print_ai("unit {0} rotate to damager".format([_cur_unit.id]), false, "crimson")
	elif _cur_unit.unit_data.visibility_data.enemies_saw.size() > 0:
		var first_enemy_grid_pos: Vector2i = _cur_unit.unit_data.visibility_data.enemies_saw.values().front()
		var angle: int = rad_to_deg(_cur_unit.unit_object.position.angle_to_point(Globals.convert_to_cell_pos(first_enemy_grid_pos)))
		_cur_unit.unit_data.update_view_direction(angle, true)
		_cur_unit.unit_data.visibility_data.clear_enemies_saw()
		_cur_unit.unit_data.visibility_data.enemy_attention_grid_pos = first_enemy_grid_pos
		Globals.print_ai("unit {0} rotate to prev saw unit".format([_cur_unit.id]), false, "crimson")

	await make_delay(0.3)
	brain_ai.decide_best_action_and_execute()


func look_around():
	_cur_unit.unit_data.look_around()
	await make_delay(1.5)


func shoot_in_random_enemy():
	var random_visible_unit = _cur_unit.unit_data.ai_settings.visible_enemies.pick_random()
	attack_enemy(random_visible_unit, UnitData.Abilities.SHOOT)


func kick_near_enemy():
	var near_enemy: Unit = GlobalUnits.units[_cur_unit.unit_data.ai_settings.enemy_stand_near]
	attack_enemy(near_enemy, UnitData.Abilities.MALEE_ATACK)


func attack_enemy(enemy: Unit, ability: UnitData.Abilities):
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.change_unit_action(ability)
	units_manager.shooting.select_enemy(ability, _cur_unit, enemy)
	await make_delay(0.5)

	units_manager.shooting.select_enemy(ability, _cur_unit, enemy)
	await make_delay(1.0)

	units_manager.change_unit_action(UnitData.Abilities.NONE)
	brain_ai.decide_best_action_and_execute()


func reload():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.shooting.reload(_cur_unit.unit_data)

	await make_delay(0.5)

	brain_ai.decide_best_action_and_execute()


func next_turn():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.next_turn()


func make_delay(time: float):
	if not GlobalMap.can_show_cur_unit():
		return

	await Globals.create_timer_and_get_signal(time)
