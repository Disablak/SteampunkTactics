extends Spatial


export(Array) var units_data = []

onready var navigation = get_node("Navigation")
onready var draw_line3d = get_node("%DrawLine3D")
onready var mouse_pointer = get_node("%MousePointer")
onready var bullet_effects = get_node("BulletEffects")

var units = null
var tween_move := Tween.new()

var cur_unit_id = -1
var cur_unit_data: UnitData
var cur_unit_object: UnitObject

var cur_unit_action = Globals.UnitAction.NONE

var cur_pointer_pos := Vector3.ZERO

var shooting_module: ShootingModule
var walking_system: WalkingModule


func _init() -> void:
	GlobalBus.connect(GlobalBus.on_unit_died_name, self, "_on_unit_died")


func _enter_tree() -> void:
	add_child(tween_move)


func _ready() -> void:
	shooting_module = ShootingModule.new(get_world(), bullet_effects)
	
	var func_ref_finish_move = funcref(shooting_module, "update_shoot_data")
	walking_system = WalkingModule.new(navigation, tween_move, draw_line3d, func_ref_finish_move)
	
	_init_units()


func _process(delta: float) -> void:
	walking_system.try_rotate_unit(delta, cur_pointer_pos, cur_unit_action)
	shooting_module.show_debug(delta)


func _init_units():
	var all_units = [
			Unit.new(0, UnitData.new(units_data[0]), get_node("%UnitObjectPlayer")),
			Unit.new(1, UnitData.new(units_data[1]), get_node("%UnitObjectEnemy"))
		]
	
	for i in all_units.size():
		GlobalUnits.units[all_units[i].id] = all_units[i]
	
	units = GlobalUnits.units
	
	set_unit_control(0, true)


func _on_unit_died(unit_id, unit_id_killer):
	var unit = units[unit_id]
	units.erase(unit_id)


func _on_InputSystem_on_unit_rotation_pressed(pos) -> void:
	cur_pointer_pos = pos


func _on_InputSystem_on_click_world(raycast_result, input_event) -> void:
	if tween_move.is_active():
		print("wait unit {0} moving".format([cur_unit_id]))
		return
	
	if raycast_result.collider.name == "Area":
		print("click on obstacle")
		return
	
	if walking_system.try_move(raycast_result, input_event, cur_unit_action):
		print("unit {0} moving".format([cur_unit_id]))
		return

	if shooting_module.try_shoot(raycast_result, input_event, cur_unit_action):
		print("unit {0} shooting".format([cur_unit_id]))
		return


func _on_InputSystem_on_mouse_hover(hover_info) -> void:
	if tween_move.is_active():
		return
	
	if cur_unit_action == Globals.UnitAction.WALK and hover_info.hover_type == Globals.MouseHoverType.GROUND:
		_draw_future_path(hover_info.pos)
	elif cur_unit_action == Globals.UnitAction.SHOOT and hover_info.hover_type == Globals.MouseHoverType.UNIT:
		shooting_module.show_shoot_hint(true, hover_info.unit_id)
	else:
		draw_line3d.clear()
		shooting_module.show_shoot_hint(false)
		TurnManager.show_hint_spend_points(0)


func _on_BtnUnitReload_pressed() -> void:
	shooting_module.reload_weapon()


func _draw_future_path(mouse_pos):
	var path = navigation.get_simple_path(cur_unit_object.global_transform.origin, mouse_pos)
	var distance = Globals.get_total_distance(path)
	var move_price = cur_unit_data.get_move_price(distance)
	var can_move = TurnManager.can_spend_time_points(move_price) 
	
	TurnManager.show_hint_spend_points(move_price)
	draw_line3d.draw_all_lines_colored(path, Color.forestgreen if can_move else Color.red)


func _change_unit_action(action_type, enable):
	var future_action
	
	if action_type == cur_unit_action or not enable:
		future_action = Globals.UnitAction.NONE;
	else:
		future_action = action_type
	
	GlobalBus.emit_signal(GlobalBus.on_unit_changed_action_name, cur_unit_id, future_action)
	cur_unit_action = future_action


func move_unit_mode(enable: bool) -> void:
	_change_unit_action(Globals.UnitAction.WALK, enable)
	if not enable:
		draw_line3d.clear()


func shoot_unit_mode(enable: bool) -> void:
	_change_unit_action(Globals.UnitAction.SHOOT, enable)
	draw_line3d.clear()


func next_unit():
	var next_unit_id = cur_unit_id + 1
	if not units.has(next_unit_id):
		next_unit_id = 0
	
	set_unit_control(next_unit_id)


func set_unit_control(unit_id, camera_focus_instantly: bool = false):
	if tween_move.is_active():
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
	cur_unit_object.unit_visual.make_outline_effect()
	
	shooting_module.set_cur_unit(units[unit_id])
	shooting_module.update_shoot_data()
	walking_system.set_cur_unit(units[unit_id])
	walking_system.cur_move_point = Vector3.ZERO
	
	TurnManager.restore_time_points()
	
	GlobalBus.emit_signal(GlobalBus.on_setted_unit_control_name, cur_unit_object, camera_focus_instantly)

