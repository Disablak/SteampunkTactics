class_name UnitsManager
extends Node2D


@export var show_enemy_raycast: bool = false

@onready var pathfinding: Pathfinding = $Pathfinding as Pathfinding
@onready var walking: WalkingModule = $WalkingModule as WalkingModule
@onready var shooting: ShootingModule = $ShootingModule as ShootingModule
@onready var line2d_manager: Line2dManager = $Line2dManager as Line2dManager
@onready var effect_manager: EffectManager = $EffectManager as EffectManager
@onready var raycaster: Raycaster = $Raycaster as Raycaster
@onready var brain_ai: BrainAI = $AiBrain as BrainAI
@onready var ai_world: AiWorld = $AiWorld as AiWorld


var units = null

var cur_unit_id = -1
var cur_unit_data: UnitData
var cur_unit_object: UnitObject

var cur_unit_action: UnitData.Abilities = UnitData.Abilities.NONE


func _ready() -> void:
	GlobalUnits.units_manager = self
	GlobalMap.raycaster = raycaster

	GlobalBus.on_unit_died.connect(_on_unit_died)
	GlobalBus.on_clicked_ability.connect(_on_clicked_ability)
	GlobalBus.on_clicked_next_turn.connect(next_turn)


func init():
	_init_units()
	pathfinding.init()

	walking.set_data(pathfinding, _on_finish_move)
	shooting.set_data(effect_manager, raycaster, pathfinding, line2d_manager)
	effect_manager.inject_data(line2d_manager)
	ai_world.init(self)

	set_unit_control(TurnManager.get_cur_turn_unit_id(), true)


func _init_units():
	var unit_objects = pathfinding.get_child(0).get_node("RootUnits").get_children()
	var id = 0

	for unit_object in unit_objects:
		if not unit_object is UnitObject:
			continue

		var unit: Unit = Unit.new(id, UnitData.new(unit_object.unit_settings, unit_object.ai_settings), unit_object)
		GlobalUnits.units[id] = unit
		id += 1

	units = GlobalUnits.units
	TurnManager.set_units_order(units.values())


func _on_clicked_ability(ability: UnitData.Abilities):
	match ability:
		UnitData.Abilities.RELOAD:
			shooting.reload(cur_unit_data)
			return

	change_unit_action(ability)


func _on_unit_died(unit_id, unit_id_killer):
	GlobalUnits.remove_unit(unit_id)
	TurnManager.remove_unit_from_order(unit_id)

	shooting.deselect_enemy()

	if TurnManager.check_is_game_over():
		GlobalsUi.message("Game is Over")
		brain_ai.is_game_over = true
		# todo send signal



func _on_finish_move() -> void:
	clear_all_lines(true)

	walking.draw_walking_cells()

	GlobalsUi.input_system.camera_controller.try_to_move_in_helper_view(cur_unit_object.position)


func _draw_future_path(grid_pos):
	if TurnManager.cur_time_points == 0:
		return

	var path: Array[Vector2i] = get_path_to_cell(grid_pos)
	var distance = Globals.get_total_distance(path)
	var move_price = cur_unit_data.get_move_price(distance)
	var can_move = walking.can_move_here(grid_pos)

	if not can_move:
		clear_all_lines()
		return

	TurnManager.show_hint_spend_points(move_price)

	clear_all_lines()

	var converted_poses = Globals.convert_grid_poses_to_cell_poses(path)
	line2d_manager.draw_path(converted_poses, true)

	_draw_enemy_visible_raycast(grid_pos)


func _draw_enemy_visible_raycast(from_grid_pos: Vector2):
	if not show_enemy_raycast:
		return

	var enemies = GlobalUnits.get_units(!cur_unit_data.is_enemy)
	for enemy in enemies:
		if not enemy.unit_object.is_visible:
			continue

		var positions = raycaster.make_ray_and_get_positions(Globals.convert_to_cell_pos(from_grid_pos), enemy.unit_object.position)
		line2d_manager.draw_ray(positions)


func next_turn():
	set_unit_control(TurnManager.get_next_unit_id())


func set_unit_control(unit_id, camera_focus_instantly: bool = false):
	if _is_camera_moving():
		printerr("camera is moving")
		return

	if walking.is_unit_moving():
		printerr("unit {0} is moving now".format([unit_id]))
		return

	if cur_unit_id == unit_id:
		printerr("its same unit {0}".format([unit_id]))
		return

	if not units.has(unit_id):
		printerr("there are no unit with id {0}".format([unit_id]))
		return

	print("next turn, cur unit {0}".format([unit_id]))

	if cur_unit_object != null:
		cur_unit_object.mark_selected(false)
		cur_unit_data.visibility_data.clear_enemies_saw()

	GlobalUnits.cur_unit_id = unit_id
	cur_unit_id = unit_id
	cur_unit_data = units[unit_id].unit_data
	cur_unit_object = units[unit_id].unit_object
	cur_unit_object.mark_selected(true)

	TurnManager.restore_time_points()

	walking.set_cur_unit(units[unit_id])

	GlobalBus.on_unit_changed_control.emit(cur_unit_id, camera_focus_instantly)

	if cur_unit_data.is_enemy:
		brain_ai.set_actions(cur_unit_data.ai_actions)
		brain_ai.decide_best_action_and_execute()


func change_unit_action(unit_action: UnitData.Abilities) -> bool:
	if unit_action != UnitData.Abilities.NONE and not cur_unit_data.has_ability(unit_action):
		GlobalsUi.message("Unit dont have ability: {0}".format([unit_action]))
		return false

	if unit_action == cur_unit_action:
		return false

	cur_unit_action = unit_action

	clear_all_lines(true)
	walking.clear_walking_cells()
	shooting.clear_malee_attack_hints()

	match unit_action:
		UnitData.Abilities.NONE:
			TurnManager.show_hint_spend_points(0)

		UnitData.Abilities.WALK:
			walking.draw_walking_cells()

		UnitData.Abilities.SHOOT:
			pass

		UnitData.Abilities.RELOAD:
			TurnManager.show_hint_spend_points(cur_unit_data.riffle.reload_price)

		UnitData.Abilities.GRENADE:
			pass

		UnitData.Abilities.MALEE_ATACK:
			shooting.update_malee_cells(units[cur_unit_id])
			shooting.show_malee_atack_cells(units[cur_unit_id])

		_:
			printerr("change unit action not implemented for {0}".format([unit_action]))

	if cur_unit_action != UnitData.Abilities.SHOOT:
		shooting.deselect_enemy()

	GlobalBus.on_unit_changed_action.emit(cur_unit_id, unit_action)

	return true


func clear_all_lines(force_clear: bool = false):
	if not force_clear and shooting.selected_enemy != null:
		return

	line2d_manager.clear_path()
	line2d_manager.clear_ray()
	line2d_manager.clear_trajectory()
	pathfinding.clear_damage_hints()


func try_move_unit_to_cell(grid_pos: Vector2):
	walking.move_unit(get_path_to_cell(grid_pos))


func get_path_to_cell(grid_pos: Vector2i) -> Array[Vector2i]:
	var start_grid_pos: Vector2i = Globals.convert_to_grid_pos(cur_unit_object.position)
	var path: Array[Vector2i] = pathfinding.get_path_to_point(start_grid_pos, grid_pos)

	return path


func _is_camera_moving() -> bool:
	if GlobalsUi.input_system == null:
		return false

	return GlobalsUi.input_system.camera_controller.is_camera_moving()


func _draw_trejectory_granade(grid_pos: Vector2):
	if not cur_unit_data.has_ability(UnitData.Abilities.GRENADE):
		return

	var cell_pos = Globals.convert_to_cell_pos(grid_pos)
	var distance := cur_unit_object.position.distance_to(cell_pos) / Globals.CELL_SIZE
	line2d_manager.draw_trajectory(cur_unit_object.position, cell_pos, distance <= cur_unit_data.grenade.settings.throw_distance)


func _on_pathfinding_on_clicked_cell(cell_info: CellInfo):
	if cur_unit_data.is_enemy:
		GlobalsUi.message("Ai's turn")
		return

	if _is_camera_moving():
		GlobalsUi.message("camera is moving")
		return

	if walking.is_unit_moving():
		GlobalsUi.message("unit walking")
		return

	if cell_info.cell_obj == null:
		GlobalsUi.message("cell no data")
		return

	if cell_info.not_cell and cell_info.cell_obj.cell_type == CellObject.CellType.DOOR:
		if pathfinding.can_open_door(cell_info.cell_obj, cur_unit_object):
			var is_opened: bool = pathfinding.is_door_opened(cell_info.cell_obj)
			pathfinding.open_door(cell_info.cell_obj, not is_opened)
			print("door is opened {0}".format([not is_opened]))
		else:
			GlobalsUi.message("Too far from door")
		return

	var is_clicked_on_unit = cell_info.unit_id != -1
	var is_clicked_on_cur_unit = is_clicked_on_unit and cell_info.unit_id == cur_unit_id

	if is_clicked_on_cur_unit:
		GlobalsUi.message("clicked on cur unit")
		return

	var is_granade_mode = cur_unit_action == UnitData.Abilities.GRENADE
	if is_granade_mode and cell_info.cell_obj.cell_type != CellObject.CellType.WALL:
		if shooting.throw_granade(GlobalUnits.units[cur_unit_id], cell_info.grid_pos):
			clear_all_lines(true)
		return

	if is_clicked_on_unit:
		shooting.update_malee_cells(units[cur_unit_id])
		var can_kick: bool = shooting.can_kick_unit(units[cur_unit_id], units[cell_info.unit_id])
		change_unit_action(UnitData.Abilities.MALEE_ATACK if can_kick else UnitData.Abilities.SHOOT)

		if shooting.select_enemy(cur_unit_action, units[cur_unit_id], units[cell_info.unit_id]):
			clear_all_lines(true)
		return

	var is_clicked_on_ground = cell_info.cell_obj.is_walkable

	if is_clicked_on_ground:
		shooting.deselect_enemy()

	if is_clicked_on_ground and cur_unit_action != UnitData.Abilities.WALK:
		change_unit_action(UnitData.Abilities.WALK)
		return

	if is_clicked_on_ground and cur_unit_action == UnitData.Abilities.WALK and not is_clicked_on_unit and walking.can_move_here(cell_info.grid_pos):
		try_move_unit_to_cell(cell_info.grid_pos)
		return


func _on_pathfinding_on_hovered_cell(cell_info: CellInfo):
	if cur_unit_data.is_enemy:
		return

	if _is_camera_moving():
		return

	if walking.is_unit_moving():
		clear_all_lines()
		return

	if cell_info.cell_obj == null:
		clear_all_lines()
		return

	var is_hovered_on_ground = cell_info.cell_obj.is_walkable
	if not is_hovered_on_ground:
		clear_all_lines()
		return

	var hovered_on_same_unit = cell_info.unit_id == cur_unit_id
	if hovered_on_same_unit:
		clear_all_lines()
		return

	if cur_unit_action == UnitData.Abilities.WALK and cell_info.unit_id == -1:
		_draw_future_path(cell_info.grid_pos)

	if cur_unit_action == UnitData.Abilities.GRENADE:
		_draw_trejectory_granade(cell_info.grid_pos)


func _on_input_system_on_pressed_esc() -> void:
	if cur_unit_data.is_enemy:
		return

	change_unit_action(UnitData.Abilities.NONE)


func _on_input_system_on_pressed_rmc() -> void:
	_on_input_system_on_pressed_esc()
