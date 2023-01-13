class_name MyWorld
extends Node2D


@onready var units_manager: UnitsManager = $UnitsManager as UnitsManager

var cached_visible_enemies: Array[Unit]


func _ready() -> void:
	GlobalMap.world = self


func try_find_visible_enemy(cur_unit: Unit) -> Array[Unit]:
	var all_enemies = GlobalUnits.get_units(!cur_unit.unit_data.unit_settings.is_enemy)
	var raycaster: Raycaster = GlobalMap.raycaster;

	var visible_points: Array[Vector2i] = GlobalUnits.units_manager.pathfinding.fog_of_war.get_team_visibility(cur_unit.unit_data.unit_settings.is_enemy)
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

	await GlobalsUi.input_system.camera_controller.on_focused

	units_manager.change_unit_action(Globals.UnitAction.SHOOT)
	units_manager.shooting.select_enemy(random_visible_unit)
	await Globals.create_timer_and_get_signal(1.0)

	units_manager.clear_all_lines()
	await Globals.create_timer_and_get_signal(0.2)

	units_manager.shooting.shoot(GlobalUnits.get_cur_unit())
	await Globals.create_timer_and_get_signal(0.5)

	units_manager.change_unit_action(Globals.UnitAction.NONE)
	units_manager.next_turn()


func walk_to_rand_cell():
	await GlobalsUi.input_system.camera_controller.on_focused

	var unit_walking : WalkingModule = units_manager.walking
	unit_walking.draw_walking_cells()

	await Globals.create_timer_and_get_signal(0.2)

	var walking_cells : PackedVector2Array = unit_walking.cached_walking_cells;
	if walking_cells.size() == 0:
		printerr("No walking cells")
	else:
		var random_cell := walking_cells[randi_range(0, walking_cells.size() - 1)]
		units_manager.change_unit_action(Globals.UnitAction.WALK)
		units_manager.try_move_unit_to_cell(random_cell)
		await unit_walking.on_finished_move

	units_manager.change_unit_action(Globals.UnitAction.NONE)
	units_manager.next_turn()


func _on_btn_granade_button_down() -> void:
	units_manager.change_unit_action_with_enable(Globals.UnitAction.GRANADE, true)


func _on_btn_move_button_down() -> void:
	units_manager.change_unit_action_with_enable(Globals.UnitAction.WALK, true)


func _on_btn_shoot_button_down() -> void:
	units_manager.change_unit_action_with_enable(Globals.UnitAction.SHOOT, true)


func _on_btn_reload_button_down() -> void:
	units_manager.reload_weapon()


func _on_btn_next_turn_button_down() -> void:
	units_manager.next_turn()
