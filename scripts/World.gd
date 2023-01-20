class_name MyWorld
extends Node2D


@onready var units_manager: UnitsManager = $UnitsManager as UnitsManager
@onready var input_system: InputSystem = $InputSystem

@export var level_scenes: Array[PackedScene]

var cached_visible_enemies: Array[Unit]


func _ready() -> void:
	GlobalMap.world = self


func init(level_id: int):
	var new_level = level_scenes[level_id].instantiate()
	units_manager.pathfinding.add_child(new_level)
	units_manager.pathfinding.move_child(new_level, 0)

	units_manager.init()
	input_system.init()


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
	var cur_unit: Unit = GlobalUnits.get_cur_unit()
	var random_visible_unit = cached_visible_enemies.pick_random()
	print("shoot! to unit_id - {0}".format([random_visible_unit.id]))

	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	units_manager.change_unit_action(UnitSettings.Abilities.SHOOT) # todo it can return fallse and unit not shoot
	units_manager.shooting.select_enemy(UnitSettings.Abilities.SHOOT, cur_unit, random_visible_unit)
	await Globals.create_timer_and_get_signal(1.0)

	units_manager.clear_all_lines()
	await Globals.create_timer_and_get_signal(0.2)

	units_manager.shooting.shoot(GlobalUnits.get_cur_unit())
	await Globals.create_timer_and_get_signal(1.2)

	units_manager.change_unit_action(UnitSettings.Abilities.NONE)
	units_manager.next_turn()


func walk_to_rand_cell():
	await Globals.wait_while(GlobalsUi.input_system.camera_controller.camera_is_moving)

	var unit_walking : WalkingModule = units_manager.walking
	unit_walking.draw_walking_cells()

	await Globals.create_timer_and_get_signal(0.2)

	var walking_cells : PackedVector2Array = unit_walking.cached_walking_cells;
	if walking_cells.size() == 0:
		printerr("No walking cells")
	else:
		var random_cell := walking_cells[randi_range(0, walking_cells.size() - 1)]
		units_manager.change_unit_action(UnitSettings.Abilities.WALK)
		units_manager.try_move_unit_to_cell(random_cell)
		await unit_walking.on_finished_move

	units_manager.change_unit_action(UnitSettings.Abilities.NONE)
	units_manager.next_turn()
