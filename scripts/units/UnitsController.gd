extends Node


const move_speed = 3
const rot_speed = 10

onready var pathfinding_system = get_parent().get_node("%PathfindingSystem")
onready var draw_line3d = get_parent().get_node("%DrawLine3D")
onready var mouse_pointer = get_parent().get_node("%MousePointer")
onready var units = GlobalUnits.units

var tween_move := Tween.new()
var cur_unit_id = -1
var cur_unit_data: UnitData
var cur_unit_object: UnitObject
var cur_target_point := Vector3.ZERO
var cur_unit_action = Globals.UnitAction.NONE

var cur_pointer_pos := Vector3.ZERO


func _init() -> void:
	GlobalBus.connect(GlobalBus.on_unit_died_name, self, "_on_unit_died")


func _enter_tree() -> void:
	add_child(tween_move)


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	_when_walk_auto_rotate_unit(cur_target_point, delta)
	_pointer_rotate_unit(delta)


func _when_walk_auto_rotate_unit(pos, delta):
	if pos == Vector3.ZERO or not tween_move.is_active():
		return
	
	var new_transform = cur_unit_object.transform.looking_at(pos, Vector3.UP)
	cur_unit_object.transform = cur_unit_object.transform.interpolate_with(new_transform, rot_speed * delta)
	cur_unit_object.rotation.x = 0


func _pointer_rotate_unit(delta):
	if cur_unit_action != Globals.UnitAction.SHOOT or tween_move.is_active():
		return
	
	cur_unit_object.look_at(cur_pointer_pos, Vector3.UP)
	cur_unit_object.rotation_degrees.x = 0


func _move_unit(pos):
	var path = pathfinding_system.find_path(cur_unit_object.global_transform.origin, pos)
	var distance = pathfinding_system.get_total_distance(path)
	if not cur_unit_data.can_move(distance):
		return
	
	cur_unit_data.remove_walk_distance(distance)
	_move_via_points(path)


func _move_via_points(points: PoolVector3Array):
	var cur_target_id = 0
	
	for point in points:
		if cur_target_id == points.size() - 1:
			cur_unit_object.unit_animator.play_anim(Globals.AnimationType.IDLE)
			draw_line3d.clear()
			cur_target_point = Vector3.ZERO
			print("finish!")
			return
		
		cur_target_point = points[cur_target_id + 1]
		
		cur_unit_object.unit_animator.play_anim(Globals.AnimationType.WALKING)
		var time_move = points[cur_target_id].distance_to(points[cur_target_id + 1]) / move_speed
		
		tween_move.interpolate_property(
			cur_unit_object,
			"translation",
			points[cur_target_id], 
			points[cur_target_id + 1],
			time_move
		)
		tween_move.start()
		
		cur_target_id += 1
		yield(tween_move, "tween_completed") 


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
	
	if _try_move(raycast_result, input_event):
		print("unit {0} moving".format([cur_unit_id]))
		return

	if _try_shoot(raycast_result, input_event):
		print("unit {0} shooting".format([cur_unit_id]))
		return


func _on_InputSystem_on_mouse_hover_cell(is_hover, cell_pos) -> void:
	mouse_pointer.visible = is_hover
	mouse_pointer.global_transform.origin = cell_pos
	
	if not is_hover:
		draw_line3d.clear()
		return
	
	if tween_move.is_active():
		return
	
	if cur_unit_action != Globals.UnitAction.WALK:
		return
	
	var path = pathfinding_system.find_path(cur_unit_object.global_transform.origin, cell_pos)
	draw_line3d.draw_all_lines(path)


func _try_move(raycast_result, input_event: InputEventMouseButton) -> bool:
	if not (input_event.pressed and input_event.button_index == 2 and raycast_result.collider.is_in_group("pathable")):
		return false
	
	if raycast_result.position == Vector3.ZERO:
		return false
		
	if cur_unit_action != Globals.UnitAction.WALK:
		return false
		
	_move_unit(raycast_result.position)
	return true


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
	enemy.unit_object.unit_animator.play_anim(Globals.AnimationType.HIT)
	enemy.unit_data.set_damage(10, cur_unit_id)
	return true


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
	
	GlobalBus.emit_signal(GlobalBus.on_setted_unit_control_name, cur_unit_object, camera_focus_instantly)


func next_unit():
	var next_unit_id = cur_unit_id + 1
	if not units.has(next_unit_id):
		next_unit_id = 0
	
	set_unit_control(next_unit_id)
	cur_unit_data.restore_walk_distance()


