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
	shooting.set_data(effect_manager, raycaster)
	
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
	_clear_all_lines()
	walking.draw_walking_cells()


func _draw_future_path(mouse_pos):
	if TurnManager.cur_time_points == 0:
		return
	
	var formatted_path: PackedVector2Array = _get_path_to_mouse_pos(mouse_pos)
	var distance = Globals.get_total_distance(formatted_path)
	var move_price = cur_unit_data.get_move_price(distance)
	var can_move = TurnManager.can_spend_time_points(move_price) 
	
	if not can_move: # dont show path if not enough money
		return
	
	TurnManager.show_hint_spend_points(move_price)
	
	_clear_all_lines()
	
	line2d_manager.draw_path(formatted_path, can_move)
	_draw_enemy_visible_raycast(mouse_pos)


func _draw_enemy_visible_raycast(from_pos: Vector2):
	if not show_enemy_raycast:
		return
	
	var tile_pos = Globals.convert_to_rect_pos(Globals.convert_to_tile_pos(from_pos))
	var enemies = GlobalUnits.get_units(!cur_unit_data.unit_settings.is_enemy)
	for enemy in enemies:
		var positions = raycaster.make_ray_and_get_positions(tile_pos, enemy.unit_object.position)
		line2d_manager.draw_ray(positions)


func next_turn():
	var next_unit_id = cur_unit_id + 1
	if not units.has(next_unit_id):
		next_unit_id = 0
	
	set_unit_control(next_unit_id)


func set_unit_control(unit_id, camera_focus_instantly: bool = false):
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
	
	GlobalBus.on_setted_unit_control.emit(cur_unit_id, camera_focus_instantly)


func change_unit_action_with_enable(unit_action, enable):
	var future_action
	
	if unit_action == cur_unit_action or not enable:
		future_action = Globals.UnitAction.NONE;
	else:
		future_action = unit_action
	
	change_unit_action(future_action)


func change_unit_action(unit_action):
	cur_unit_action = unit_action
	
	_clear_all_lines()
	
	if cur_unit_action == Globals.UnitAction.WALK:
		walking.draw_walking_cells()
	else:
		walking.clear_walking_cells()
	
	GlobalBus.on_unit_changed_action.emit(cur_unit_id, unit_action)


func reload_weapon():
	shooting.reload(cur_unit_data)


func _clear_all_lines():
	line2d_manager.clear_path()
	line2d_manager.clear_ray()


func try_move_unit_to_cell(cell_pos: Vector2):
	walking.move_unit(_get_path_to_cell(cell_pos))


func _get_path_to_mouse_pos(mouse_pos: Vector2) -> PackedVector2Array:
	var cell_pos: Vector2 = Globals.convert_to_tile_pos(mouse_pos)
	return _get_path_to_cell(cell_pos)


func _get_path_to_cell(cell_pos: Vector2) -> PackedVector2Array:
	var unit_pos: Vector2 = Globals.convert_to_tile_pos(cur_unit_object.position)
	var path: PackedVector2Array = pathfinding.get_path_to_point(unit_pos, cell_pos)
	var formatted_path: PackedVector2Array = Globals.convert_tile_points_to_rect(path)
	
	return formatted_path


func _on_pathfinding_on_clicked_cell(hover_info) -> void:
	if walking.is_unit_moving():
		return
	
	if hover_info.cell_obj == null:
		return
	
	var is_clicked_on_unit = hover_info.unit_id != -1
	var is_clicked_on_same_unit = is_clicked_on_unit and hover_info.unit_id == cur_unit_id
	
	if is_clicked_on_same_unit and cur_unit_action != Globals.UnitAction.RELOAD:
		change_unit_action(Globals.UnitAction.RELOAD)
		return
	
	if is_clicked_on_same_unit and cur_unit_action == Globals.UnitAction.RELOAD:
		reload_weapon()
		return
	
	if is_clicked_on_same_unit:
		return
	
	if is_clicked_on_unit and cur_unit_action != Globals.UnitAction.SHOOT:
		change_unit_action(Globals.UnitAction.SHOOT)
		return
	
	if is_clicked_on_unit and cur_unit_action == Globals.UnitAction.SHOOT:
		shooting.shoot(units[cur_unit_id], units[hover_info.unit_id])
		return
	
	if is_clicked_on_unit:
		return
	
	var is_clicked_on_ground = hover_info.cell_obj.obj_type == CellObject.AtlasObjectType.GROUND
	
	if is_clicked_on_ground and cur_unit_action != Globals.UnitAction.WALK:
		change_unit_action(Globals.UnitAction.WALK)
		return
	
	if is_clicked_on_ground and cur_unit_action == Globals.UnitAction.WALK:
		var path : PackedVector2Array = _get_path_to_mouse_pos(hover_info.pos)
		walking.move_unit(path)
		return


func _on_pathfinding_on_hovered_cell(hover_info) -> void:
	if walking.is_unit_moving():
		_clear_all_lines()
		return
	
	if hover_info.cell_obj == null:
		_clear_all_lines()
		return
	
	if hover_info.cell_obj.obj_type != CellObject.AtlasObjectType.GROUND:
		_clear_all_lines()
		return
	
	if cur_unit_action == Globals.UnitAction.WALK and hover_info.unit_id == -1:
		_draw_future_path(hover_info.pos)


func _on_input_system_on_pressed_esc() -> void:
	change_unit_action(Globals.UnitAction.NONE)
