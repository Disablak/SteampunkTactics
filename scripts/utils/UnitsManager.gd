class_name UnitsManager
extends Node2D


@export var units_data: Array = []
@export var unit_objects: Array[NodePath]

@onready var pathfinding: Pathfinding = $Pathfinding as Pathfinding
@onready var walking: WalkingModule = $WalkingModule as WalkingModule
@onready var shooting: ShootingModule = $ShootingModule as ShootingModule
@onready var line2d: Line2D = $Line2d as Line2D
@onready var effect_manager: EffectManager = $EffectManager as EffectManager
@onready var raycaster: Raycaster = $Raycaster as Raycaster
@onready var brain_ai: BrainAI = $BrainAI as BrainAI

var units = null

var cur_unit_id = -1
var cur_unit_data: UnitData
var cur_unit_object: UnitObject

var cur_unit_action = Globals.UnitAction.NONE


func _ready() -> void:
	walking.set_data(pathfinding, _on_finish_move)
	
	_init_units()
	GlobalUnits.units_manager = self
	GlobalUnits.calc_units_team()


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
	var unit = units[unit_id]
	units.erase(unit_id)


func _on_finish_move() -> void:
#	shooting_module.create_shoot_data()
#	_try_to_enemy_continue_turn()
	line2d.clear_points()


func _draw_future_path(mouse_pos):
	var formatted_path: PackedVector2Array = _get_formatted_path(mouse_pos)
	var distance = Globals.get_total_distance(formatted_path)
	var move_price = cur_unit_data.get_move_price(distance)
	var can_move = TurnManager.can_spend_time_points(move_price) 
	
	TurnManager.show_hint_spend_points(move_price)
	
	line2d.default_color = Color.FOREST_GREEN if can_move else Color.RED
	line2d.clear_points()
	for point in formatted_path:
		line2d.add_point(point)

func next_unit():
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
	
	GlobalUnits.cur_unit_id = unit_id
	cur_unit_id = unit_id
	cur_unit_data = units[unit_id].unit_data
	cur_unit_object = units[unit_id].unit_object
	#cur_unit_object.unit_visual.make_outline_effect()
	
	walking.set_cur_unit(units[unit_id])
	
	TurnManager.restore_time_points()
	
	if cur_unit_data.unit_settings.is_enemy:
#		brain_ai.start_brain()
#		brain_ai.decide_best_action_and_execute()
		pass
	
	GlobalBus.on_setted_unit_control.emit(cur_unit_id, camera_focus_instantly)


func change_unit_action(unit_action, enable):
	var future_action
	
	if unit_action == cur_unit_action or not enable:
		future_action = Globals.UnitAction.NONE;
	else:
		future_action = unit_action
	
	line2d.clear_points()
	cur_unit_action = unit_action
	GlobalBus.on_unit_changed_action.emit(cur_unit_id, unit_action)


func reload_weapon():
	if not TurnManager.can_spend_time_points(cur_unit_data.weapon.reload_price):
		return
	
	TurnManager.spend_time_points(TurnManager.TypeSpendAction.RELOADING, cur_unit_data.weapon.reload_price)
	cur_unit_data.reload_weapon()


func _get_formatted_path(mouse_pos: Vector2) -> PackedVector2Array:
	var unit_pos: Vector2 = Globals.convert_to_tile_pos(cur_unit_object.position)
	var target_pos: Vector2 = Globals.convert_to_tile_pos(mouse_pos)
	
	var path: PackedVector2Array = pathfinding.get_path_to_point(unit_pos, target_pos)
	var formatted_path: PackedVector2Array = Globals.convert_tile_points_to_rect(path)
	
	return formatted_path


func _on_pathfinding_on_clicked_cell(hover_info) -> void:
	if walking.is_unit_moving():
		return
	
	if cur_unit_action == Globals.UnitAction.WALK and hover_info.unit_id == -1:
		var formatted_path: PackedVector2Array = _get_formatted_path(hover_info.pos)
		walking.move_unit(formatted_path)
	elif cur_unit_action == Globals.UnitAction.SHOOT and hover_info.unit_id != -1:
		shooting.shoot(units[cur_unit_id], units[hover_info.unit_id], effect_manager, raycaster)


func _on_pathfinding_on_hovered_cell(hover_info) -> void:
	if walking.is_unit_moving():
		return
	
	if cur_unit_action == Globals.UnitAction.WALK and hover_info.unit_id == -1:
		_draw_future_path(hover_info.pos)
