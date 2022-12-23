class_name UnitsManager
extends Node2D


@export var show_enemy_raycast: bool = false
@export var units_data: Array = []
@export var unit_objects: Array[NodePath]

@onready var pathfinding: Pathfinding = $Pathfinding as Pathfinding
@onready var walking: WalkingModule = $WalkingModule as WalkingModule
@onready var shooting: ShootingModule = $ShootingModule as ShootingModule
@onready var line2d_manager: Line2dManager = $Line2dManager as Line2dManager
@onready var effect_manager: EffectManager = $EffectManager as EffectManager
@onready var raycaster: Raycaster = $Raycaster as Raycaster
@onready var brain_ai: BrainAI = $BrainAI as BrainAI


var units = null

var cur_unit_id = -1
var cur_unit_data: UnitData
var cur_unit_object: UnitObject

var cur_unit_action: Globals.UnitAction = Globals.UnitAction.NONE


func _ready() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)

	walking.set_data(pathfinding, _on_finish_move)
	shooting.set_data(effect_manager, raycaster, pathfinding)

	_init_units()
	GlobalUnits.units_manager = self
	GlobalMap.raycaster = raycaster


func _init_units():
	var all_units = [
			Unit.new(0, UnitData.new(units_data[0]), get_node(unit_objects[0])),
			Unit.new(1, UnitData.new(units_data[1]), get_node(unit_objects[1]))
		]

	for i in all_units.size():
		GlobalUnits.units[all_units[i].id] = all_units[i]

	units = GlobalUnits.units

	set_unit_control(0, true)


func _on_unit_died(unit_id, unit_id_killer):
	GlobalUnits.remove_unit(unit_id)


func _on_finish_move() -> void:
	clear_all_lines()
	walking.draw_walking_cells()


func _draw_future_path(mouse_pos):
	if TurnManager.cur_time_points == 0:
		return

	var path: PackedVector2Array = _get_path_to_cell(mouse_pos)
	var distance = Globals.get_total_distance(path)
	var move_price = cur_unit_data.get_move_price(distance)
	var can_move = TurnManager.can_spend_time_points(move_price)

	if not can_move: # dont show path if not enough money
		return

	TurnManager.show_hint_spend_points(move_price)

	clear_all_lines()

	line2d_manager.draw_path(path, can_move)
	_draw_enemy_visible_raycast(mouse_pos)


func _draw_enemy_visible_raycast(from_pos: Vector2):
	if not show_enemy_raycast:
		return

	var enemies = GlobalUnits.get_units(!cur_unit_data.unit_settings.is_enemy)
	for enemy in enemies:
		var positions = raycaster.make_ray_and_get_positions(from_pos, enemy.unit_object.position)
		line2d_manager.draw_ray(positions)


func next_turn():
	var next_unit_id = cur_unit_id + 1
	if not units.has(next_unit_id):
		next_unit_id = 0

	set_unit_control(next_unit_id)


func set_unit_control(unit_id, camera_focus_instantly: bool = false):
	if _is_camera_moving():
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

	GlobalUnits.cur_unit_id = unit_id
	cur_unit_id = unit_id
	cur_unit_data = units[unit_id].unit_data
	cur_unit_object = units[unit_id].unit_object
	cur_unit_object.mark_selected(true)

	TurnManager.restore_time_points()

	walking.set_cur_unit(units[unit_id])

	if cur_unit_data.unit_settings.is_enemy:
		brain_ai.decide_best_action_and_execute()

	GlobalBus.on_unit_changed_control.emit(cur_unit_id, camera_focus_instantly)


func change_unit_action_with_enable(unit_action, enable):
	var future_action

	if unit_action == cur_unit_action or not enable:
		future_action = Globals.UnitAction.NONE;
	else:
		future_action = unit_action

	change_unit_action(future_action)


func change_unit_action(unit_action: Globals.UnitAction):
	cur_unit_action = unit_action

	clear_all_lines()
	walking.clear_walking_cells()

	match unit_action:
		Globals.UnitAction.NONE:
			TurnManager.show_hint_spend_points(0)

		Globals.UnitAction.WALK:
			walking.draw_walking_cells()

		Globals.UnitAction.SHOOT:
			TurnManager.show_hint_spend_points(cur_unit_data.weapon.shoot_price)

			var unit_pos = cur_unit_object.position
			var positions = raycaster.make_ray_and_get_positions(unit_pos, shooting.selected_enemy.unit_object.position, true)
			line2d_manager.draw_ray(positions)

		Globals.UnitAction.RELOAD:
			TurnManager.show_hint_spend_points(cur_unit_data.weapon.reload_price)

		Globals.UnitAction.GRANADE:
			pass

		_:
			printerr("change unit action not implemented for {0}".format([unit_action]))

	if cur_unit_action != Globals.UnitAction.SHOOT:
		shooting.deselect_enemy()

	GlobalBus.on_unit_changed_action.emit(cur_unit_id, unit_action)


func reload_weapon():
	shooting.reload(cur_unit_data)


func clear_all_lines():
	line2d_manager.clear_path()
	line2d_manager.clear_ray()
	line2d_manager.clear_trajectory()


func try_move_unit_to_cell(cell_pos: Vector2):
	walking.move_unit(_get_path_to_cell(cell_pos))


func _get_path_to_cell(cell_pos: Vector2) -> PackedVector2Array:
	var unit_pos: Vector2 = cur_unit_object.position
	var path: PackedVector2Array = pathfinding.get_path_to_point(unit_pos, cell_pos)

	return path


func _is_camera_moving() -> bool:
	if GlobalsUi.input_system == null:
		return false

	return GlobalsUi.input_system.camera_controller.is_camera_moving()


func _on_pathfinding_on_clicked_cell(cell_info: CellInfo):
	if _is_camera_moving():
		return

	if walking.is_unit_moving():
		return

	if cell_info.cell_obj == null:
		return

	var is_clicked_on_unit = cell_info.unit_id != -1
	var is_clicked_on_same_unit = is_clicked_on_unit and cell_info.unit_id == cur_unit_id

	if is_clicked_on_same_unit and cur_unit_action != Globals.UnitAction.RELOAD:
		change_unit_action(Globals.UnitAction.RELOAD)
		return

	if is_clicked_on_same_unit and cur_unit_action == Globals.UnitAction.RELOAD:
		reload_weapon()
		return

	if is_clicked_on_same_unit:
		return

	if is_clicked_on_unit and cur_unit_action != Globals.UnitAction.SHOOT:
		shooting.select_enemy(units[cell_info.unit_id])
		change_unit_action(Globals.UnitAction.SHOOT)
		return

	if is_clicked_on_unit and cur_unit_action == Globals.UnitAction.SHOOT:
		shooting.shoot(units[cur_unit_id])
		clear_all_lines()
		return

	if is_clicked_on_unit:
		return

	var is_clicked_on_ground = cell_info.cell_obj.cell_type == CellObject.CellType.GROUND
	var is_granade_mode = cur_unit_action == Globals.UnitAction.GRANADE

	if is_clicked_on_ground and is_granade_mode:
		shooting.throw_granade(cur_unit_id, cell_info.cell_obj.position)
		return

	if is_clicked_on_ground and cur_unit_action != Globals.UnitAction.WALK:
		change_unit_action(Globals.UnitAction.WALK)
		return

	if is_clicked_on_ground and cur_unit_action == Globals.UnitAction.WALK:
		var path : PackedVector2Array = _get_path_to_cell(cell_info.cell_pos)
		walking.move_unit(path)
		return


func _on_pathfinding_on_hovered_cell(cell_info: CellInfo):
	if _is_camera_moving():
		return

	if walking.is_unit_moving():
		clear_all_lines()
		return

	if cell_info.cell_obj == null:
		clear_all_lines()
		return

	if cell_info.cell_obj.cell_type != CellObject.CellType.GROUND:
		clear_all_lines()
		return

	var hovered_on_same_unit = cell_info.unit_id == cur_unit_id
	if hovered_on_same_unit:
		clear_all_lines()
		return

	if cur_unit_action == Globals.UnitAction.WALK and cell_info.unit_id == -1:
		_draw_future_path(cell_info.cell_obj.position)

	if cur_unit_action == Globals.UnitAction.GRANADE:
		line2d_manager.draw_trajectory(cur_unit_object.position, cell_info.cell_obj.position)


func _on_input_system_on_pressed_esc() -> void:
	change_unit_action(Globals.UnitAction.NONE)

