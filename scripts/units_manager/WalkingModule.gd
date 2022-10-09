class_name WalkingModule
extends RefCounted


const ROTATION_SPEED = 10
const MOVING_SPEED = 3


var cur_unit_object: UnitObject
var cur_unit_data: UnitData
var cur_move_point: Vector3

var tween_move: Tween
var draw_line3d: DrawLine3D
var callable_finish_move: Callable
var callable_create_tween: Callable


func _init(draw_line3d, callable_finish_move: Callable, callable_create_tween: Callable):
	self.draw_line3d = draw_line3d
	self.callable_finish_move = callable_finish_move
	self.callable_create_tween = callable_create_tween


func set_cur_unit(unit: Unit):
	cur_unit_object = unit.unit_object
	cur_unit_data = unit.unit_data


func try_rotate_unit(delta, pointer_target_pos, cur_unit_action):
	if cur_move_point == Vector3.ZERO and cur_unit_action != Globals.UnitAction.SHOOT:
		return
	
	var rotation_target = cur_move_point if is_unit_moving() else pointer_target_pos
	_rotate_unit(rotation_target, delta)


func is_unit_moving() -> bool:
	return tween_move != null and tween_move.is_running()


func _rotate_unit(target_pos, delta):
	target_pos.y = 0.0
	var new_transform = cur_unit_object.transform.looking_at(target_pos, Vector3.UP)
	cur_unit_object.transform = cur_unit_object.transform.interpolate_with(new_transform, ROTATION_SPEED * delta)
	cur_unit_object.rotation.x = 0
	cur_unit_object.rotation.z = 0


func try_move(raycast_result, input_event: InputEventMouseButton, cur_unit_action) -> bool:
	if not (input_event.pressed and input_event.button_index == 2 and raycast_result.collider.is_in_group("pathable")):
		return false
	
	if raycast_result.position == Vector3.ZERO:
		return false
		
	if cur_unit_action != Globals.UnitAction.WALK:
		return false
		
	move_unit(raycast_result.position)
	return true


func move_unit(pos):
	var path = cur_unit_object.get_move_path(pos)
	var price_time_points = get_move_price(path)
	if not TurnManager.can_spend_time_points(price_time_points):
		return
	
	TurnManager.spend_time_points(TurnManager.TypeSpendAction.WALKING, price_time_points)
	_move_via_points(path)


func get_move_price_to_pos(pos : Vector3) -> int:
	var path = cur_unit_object.get_move_path(pos)
	var price_time_points = get_move_price(path)
	return price_time_points


func get_move_price(path : PackedVector3Array) -> int:
	var distance = Globals.get_total_distance(path)
	var price_time_points = cur_unit_data.get_move_price(distance)
	return price_time_points


func _move_via_points(points: PackedVector3Array):
	var cur_target_id = 0
	
	for point in points:
		if cur_target_id == points.size() - 1:
			_on_unit_finished_move()
			return
		
		cur_move_point = points[cur_target_id + 1]
		
		cur_unit_object.unit_animator.play_anim(Globals.AnimationType.WALKING)
		var time_move = points[cur_target_id].distance_to(points[cur_target_id + 1]) / MOVING_SPEED
		
		tween_move = callable_create_tween.call()
		tween_move.tween_property(
			cur_unit_object,
			"position",
			points[cur_target_id + 1],
			time_move
		).from(points[cur_target_id])
		
		cur_target_id += 1
		await tween_move.finished 


func _on_unit_finished_move():
	cur_unit_object.unit_animator.play_anim(Globals.AnimationType.IDLE)
	draw_line3d.clear()
	cur_move_point = Vector3.ZERO
	
	callable_finish_move.call()
