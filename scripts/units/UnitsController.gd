extends Node


signal on_called_tooltip(show, world_pos, text)

const move_speed = 3
const rot_speed = 10

export(Array) var units_data = []

onready var navigation = get_node("Navigation")
onready var shooting_system = get_node("ShootingSystem")
onready var draw_line3d = get_node("%DrawLine3D")
onready var mouse_pointer = get_node("%MousePointer")
onready var units

var tween_move := Tween.new()
var cur_unit_id = -1
var cur_unit_data: UnitData
var cur_unit_object: UnitObject
var cur_target_point := Vector3.ZERO
var cur_unit_action = Globals.UnitAction.NONE

var cur_pointer_pos := Vector3.ZERO

var walking_system: WalkingSystem
var shoot_data = ShootData.new()


func _init() -> void:
	GlobalBus.connect(GlobalBus.on_unit_died_name, self, "_on_unit_died")


func _enter_tree() -> void:
	add_child(tween_move)


func _ready() -> void:
	var func_ref_finish_move = funcref(self, "_update_shoot_data")
	walking_system = WalkingSystem.new(navigation, tween_move, draw_line3d, func_ref_finish_move)
	
	_init_units()


func _process(delta: float) -> void:
	walking_system.try_rotate_unit(delta, cur_pointer_pos, cur_unit_action)


func _init_units():
	var all_units = [
			Unit.new(0, UnitData.new(units_data[0]), get_node("%UnitObjectPlayer")),
			Unit.new(1, UnitData.new(units_data[1]), get_node("%UnitObjectEnemy"))
		]
	
	for i in all_units.size():
		GlobalUnits.units[all_units[i].id] = all_units[i]
	
	units = GlobalUnits.units
	
	set_unit_control(0, true)


func _update_shoot_data():
	shoot_data = ShootData.new()
	shoot_data.shooter_id = cur_unit_id
	shoot_data.shooter_pos = cur_unit_object.global_transform.origin


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

	if _try_shoot(raycast_result, input_event):
		print("unit {0} shooting".format([cur_unit_id]))
		return


func _on_InputSystem_on_mouse_hover(hover_info) -> void:
	if tween_move.is_active():
		return
	
	if cur_unit_action == Globals.UnitAction.WALK and hover_info.hover_type == Globals.MouseHoverType.GROUND:
		_draw_future_path(hover_info.pos)
	elif cur_unit_action == Globals.UnitAction.SHOOT and hover_info.hover_type == Globals.MouseHoverType.UNIT:
		_show_shoot_hint(true, hover_info.unit_id)
	else:
		draw_line3d.clear()
		_show_shoot_hint(false)


func _draw_future_path(mouse_pos):
	var path = navigation.get_simple_path(cur_unit_object.global_transform.origin, mouse_pos)
	var distance = Globals.get_total_distance(path)
	var can_move = cur_unit_data.can_move(distance)
	draw_line3d.draw_all_lines_colored(path, Color.forestgreen if can_move else Color.red)


func _show_shoot_hint(show, unit_id = -1):
	if not show or cur_unit_id == unit_id or not units.has(unit_id):
		_emit_show_tooltip(show, Vector3.ZERO, "")
		return
	
	var enemy_object = units[unit_id].unit_object
	
	shoot_data.enemy_id = unit_id
	shoot_data.enemy_pos = enemy_object.global_transform.origin
	shoot_data.weapon = cur_unit_data.weapon
	shoot_data.distance = cur_unit_object.global_transform.origin.distance_to(enemy_object.global_transform.origin)
	shoot_data.shoot_point = cur_unit_object.get_shoot_point()
	shoot_data.target_points = enemy_object.get_hit_points()
	
	var shoot_result: ShootData = shooting_system.get_hit_result(shoot_data)
	var chance_hit = "chance hit: {0}% \n".format(["%0.0f" % (shoot_result.hit_chance * 100)])
	var visibility = "visibility: {0}% \n".format(["%0.0f" % (shoot_result.visibility * 100)])
	var distance = "distance : {0}m \n".format(["%0.1f" % shoot_result.distance])
	_emit_show_tooltip(show, enemy_object.global_transform.origin, visibility + distance + chance_hit)


func _try_shoot(raycast_result, input_event: InputEventMouseButton):
	if cur_unit_action != Globals.UnitAction.SHOOT:
		return false
	
	if not (input_event.pressed and input_event.button_index == 1):
		return false
	
	var unit_object = raycast_result.collider.get_parent() as UnitObject
	if not unit_object:
		return false
	
	if unit_object == cur_unit_object:
		printerr("unit clicked on yourself")
		return false
	
	cur_unit_object.unit_animator.play_anim(Globals.AnimationType.SHOOTING)
	
	var enemy = units[unit_object.unit_id]
	var is_hitted: bool = shooting_system.is_hitted(shoot_data) # yea im sure that here we have all data thats I need
	
	if is_hitted:
		enemy.unit_object.unit_animator.play_anim(Globals.AnimationType.HIT)
		enemy.unit_data.set_damage(cur_unit_data.weapon.damage, cur_unit_id)
	
	return is_hitted


func _change_unit_action(action_type, enable):
	var future_action
	
	if action_type == cur_unit_action or not enable:
		future_action = Globals.UnitAction.NONE;
	else:
		future_action = action_type
	
	GlobalBus.emit_signal(GlobalBus.on_unit_changed_action_name, cur_unit_id, future_action)
	cur_unit_action = future_action


func _emit_show_tooltip(show, world_pos, text):
	emit_signal("on_called_tooltip", show, world_pos, text)


func move_unit_mode(enable: bool) -> void:
	_change_unit_action(Globals.UnitAction.WALK, enable)
	if not enable:
		draw_line3d.clear()


func shoot_unit_mode(enable: bool) -> void:
	_change_unit_action(Globals.UnitAction.SHOOT, enable)
	draw_line3d.clear()


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
	
	cur_unit_id = unit_id
	cur_unit_data = units[unit_id].unit_data
	cur_unit_object = units[unit_id].unit_object
	cur_target_point = Vector3.ZERO
	
	walking_system.set_cur_unit(units[unit_id])
	walking_system.cur_move_point = Vector3.ZERO
	
	GlobalBus.emit_signal(GlobalBus.on_setted_unit_control_name, cur_unit_object, camera_focus_instantly)


func next_unit():
	var next_unit_id = cur_unit_id + 1
	if not units.has(next_unit_id):
		next_unit_id = 0
	
	set_unit_control(next_unit_id)
	cur_unit_data.restore_walk_distance()
	_update_shoot_data()
