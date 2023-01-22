class_name AiWorld
extends Node2D


var cached_visible_enemies: Array[Unit]
var cached_walking_cell_target: Vector2i
var cacned_walking_cell_price: int

var units_manager: UnitsManager
var brain_ai: BrainAI

var _cur_unit: Unit:
	get: return GlobalUnits.get_cur_unit()


func _ready() -> void:
	GlobalMap.ai_world = self


func init(units_manager: UnitsManager):
	self.units_manager = units_manager
	self.brain_ai = units_manager.brain_ai


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
	var random_visible_unit = cached_visible_enemies.pick_random()
	print("shoot! to unit_id - {0}".format([random_visible_unit.id]))

	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.change_unit_action(UnitSettings.Abilities.SHOOT) # todo it can return fallse and unit not shoot
	units_manager.shooting.select_enemy(UnitSettings.Abilities.SHOOT, _cur_unit, random_visible_unit)
	await Globals.create_timer_and_get_signal(1.0)

	units_manager.clear_all_lines(true)
	await Globals.create_timer_and_get_signal(0.2)

	units_manager.shooting.select_enemy(UnitSettings.Abilities.SHOOT, _cur_unit, random_visible_unit) # confirm shoot
	await Globals.create_timer_and_get_signal(1.2)

	units_manager.change_unit_action(UnitSettings.Abilities.NONE)

	brain_ai.decide_best_action_and_execute()


func find_walk_cell_and_get_price() -> int:
	var unit_walking: WalkingModule = units_manager.walking
	unit_walking.update_walking_cells()

	var walking_cells: Array[Vector2i] = MyMath.arr_intersect(unit_walking.cached_walking_cells, _cur_unit.unit_data.ai_settings.walking_zone_cells);
	if walking_cells.size() != 0:
		cached_walking_cell_target = walking_cells.pick_random()
		var path := units_manager.get_path_to_cell(cached_walking_cell_target)
		var price_move := unit_walking.get_move_price(path)
		cacned_walking_cell_price = price_move
	else:
		cached_walking_cell_target = Vector2i.ZERO
		cacned_walking_cell_price = 999

	return cacned_walking_cell_price


func walk_to_rand_cell():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	var unit_walking : WalkingModule = units_manager.walking
	unit_walking.draw_walking_cells()

	await Globals.create_timer_and_get_signal(0.2)

	units_manager.change_unit_action(UnitSettings.Abilities.WALK)
	units_manager.try_move_unit_to_cell(cached_walking_cell_target)
	await unit_walking.on_finished_move

	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.change_unit_action(UnitSettings.Abilities.NONE)

	brain_ai.decide_best_action_and_execute()


func reload():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.shooting.reload(_cur_unit.unit_data)

	await Globals.create_timer_and_get_signal(0.5)

	brain_ai.decide_best_action_and_execute()


func next_turn():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.next_turn()







