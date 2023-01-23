class_name AiWorld
extends Node2D


var cached_visible_enemies: Array[Unit]
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


func try_find_visible_enemy(cur_unit: Unit) -> Array[Unit]:
	var all_enemies = GlobalUnits.get_units(!cur_unit.unit_data.is_enemy)
	var raycaster: Raycaster = GlobalMap.raycaster;

	var visible_points: Array[Vector2i] = GlobalUnits.units_manager.pathfinding.fog_of_war.get_team_visibility(cur_unit.unit_data.is_enemy)
	cached_visible_enemies.clear()

	for enemy in all_enemies:
		var is_enemy_visible := raycaster.make_ray_check_no_obstacle(cur_unit.unit_object.position, enemy.unit_object.position)
		if not is_enemy_visible:
			continue

		if visible_points.has(Globals.convert_to_grid_pos(enemy.unit_object.position)):
			cached_visible_enemies.append(enemy)

	return cached_visible_enemies


func cur_unit_shoot_to_visible_enemy():
	var random_visible_unit := cached_visible_enemies.pick_random()
	attack_enemy(random_visible_unit, UnitSettings.Abilities.SHOOT)


func find_walk_cell_and_get_price() -> int:
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


func find_path_to_near_enemy() -> Array[Vector2i]:
	var visible_enemy = try_find_visible_enemy(_cur_unit)
	var shortest_path: Array[Vector2i]
	var nearest_unit_id: int = -1

	for unit in visible_enemy:
		if units_manager.pathfinding.has_path(_cur_unit.unit_object.grid_pos, unit.unit_object.grid_pos):
			var path = units_manager.pathfinding.get_path_to_point(_cur_unit.unit_object.grid_pos, unit.unit_object.grid_pos)
			if shortest_path.size() == 0 or shortest_path.size() > path.size():
				shortest_path = path
				nearest_unit_id = unit.id

	if nearest_unit_id == -1:
		printerr("not found visible unit")
		return []

	var nearest_unit: Unit = GlobalUnits.units[nearest_unit_id]
	var points_around_unit := units_manager.pathfinding.get_grid_poses_by_pattern(nearest_unit.unit_object.grid_pos, Globals.CELL_AREA_FOUR_DIR)

	shortest_path.clear()
	for grid_pos in points_around_unit:
		if units_manager.pathfinding.has_path(_cur_unit.unit_object.grid_pos, grid_pos):
			var path = units_manager.pathfinding.get_path_to_point(_cur_unit.unit_object.grid_pos, grid_pos)
			if shortest_path.size() == 0 or shortest_path.size() > path.size():
				shortest_path = path

	if shortest_path.size() == 0:
		printerr("not found path to unit")
		return []

	_cur_unit.unit_data.ai_settings.shortest_path_to_enemy = shortest_path
	_cur_unit.unit_data.ai_settings.nearest_enemy_id = nearest_unit_id

	return shortest_path


func is_any_enemy_near_unit() -> bool:
	var points_around_unit := units_manager.pathfinding.get_grid_poses_by_pattern(_cur_unit.unit_object.grid_pos, Globals.CELL_AREA_FOUR_DIR)

	for grid_pos in points_around_unit:
		var unit: Unit = units_manager.pathfinding.get_unit_on_cell(grid_pos)
		if unit != null:
			_cur_unit.unit_data.ai_settings.enemy_stand_near = unit.id
			return true

	_cur_unit.unit_data.ai_settings.enemy_stand_near = -1
	return false


func get_max_price_move_to_enemy() -> int:
	var available_cells_to_walk: int = floori(float(TurnManager.cur_time_points) / _cur_unit.unit_data.unit_settings.walk_speed)
	if available_cells_to_walk == 0:
		return 9999

	var price = available_cells_to_walk * _cur_unit.unit_data.unit_settings.walk_speed
	return price


func walk_to_near_enemy():
	var available_cells_to_walk: int = floori(float(TurnManager.cur_time_points) / _cur_unit.unit_data.unit_settings.walk_speed)
	var idx = min(available_cells_to_walk, _cur_unit.unit_data.ai_settings.shortest_path_to_enemy.size() - 1)
	var target_point: Vector2i = _cur_unit.unit_data.ai_settings.shortest_path_to_enemy[idx]

	walk_to(target_point)


func walk_to_rand_cell():
	walk_to(cached_walking_cell_target)


func walk_to(grid_pos: Vector2i):
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	walking.draw_walking_cells()
	await Globals.create_timer_and_get_signal(0.2)

	units_manager.change_unit_action(UnitSettings.Abilities.WALK)
	units_manager.try_move_unit_to_cell(grid_pos)
	await walking.on_finished_move
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.change_unit_action(UnitSettings.Abilities.NONE)
	brain_ai.decide_best_action_and_execute()


func attack_enemy(enemy: Unit, ability: UnitSettings.Abilities):
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.change_unit_action(ability)
	units_manager.shooting.select_enemy(ability, _cur_unit, enemy)
	await Globals.create_timer_and_get_signal(0.5)

	units_manager.shooting.select_enemy(ability, _cur_unit, enemy)
	await Globals.create_timer_and_get_signal(1.0)

	units_manager.change_unit_action(UnitSettings.Abilities.NONE)
	brain_ai.decide_best_action_and_execute()


func reload():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.shooting.reload(_cur_unit.unit_data)

	await Globals.create_timer_and_get_signal(0.5)

	brain_ai.decide_best_action_and_execute()


func kick_near_enemy():
	var near_enemy: Unit = GlobalUnits.units[_cur_unit.unit_data.ai_settings.enemy_stand_near]
	attack_enemy(near_enemy, UnitSettings.Abilities.MALEE_ATACK)


func next_turn():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.next_turn()







