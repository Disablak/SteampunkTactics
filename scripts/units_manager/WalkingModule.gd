class_name WalkingModule
extends RefCounted


const ROTATION_SPEED = 10
const MOVING_SPEED = 3


var cur_unit_object: UnitObject
var cur_unit_data: UnitData
var cur_move_point: Vector3

var navigation: Node3D
var tween_move: Tween
var draw_line3d: DrawLine3D
var callable_finish_move: Callable


func _init(navigation, tween_move, draw_line3d, callable_finish_move: Callable):
	self.navigation = navigation
	self.tween_move = tween_move
	self.draw_line3d = draw_line3d
	self.callable_finish_move = callable_finish_move


func _ready() -> void:
	pass


func set_cur_unit(unit: Unit):
	cur_unit_object = unit.unit_object
	cur_unit_data = unit.unit_data


func try_rotate_unit(delta, pointer_target_pos, cur_unit_action):
	if cur_move_point == Vector3.ZERO and cur_unit_action != Globals.UnitAction.SHOOT:
		return
	
	var rotation_target = cur_move_point if tween_move.is_active() else pointer_target_pos
	_rotate_unit(rotation_target, delta)


func _rotate_unit(target_pos, delta):
	target_pos.y = 0.0
	var new_transform = cur_unit_object.transform.looking_at(target_pos, Vector3.UP)
	cur_unit_object.transform = cur_unit_object.transform.interpolate_with(new_transform, ROTATION_SPEED * delta)
	cur_unit_object.rotation_degrees.x = 0


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
	var path = navigation.get_simple_path(cur_unit_object.global_transform.origin, pos)
	var distance = Globals.get_total_distance(path)
	var price_time_points = cur_unit_data.get_move_price(distance)
	if not TurnManager.can_spend_time_points(price_time_points):
		return
	
	TurnManager.spend_time_points(TurnManager.TypeSpendAction.WALKING, price_time_points)
	_move_via_points(path)


func _move_via_points(points: PackedVector3Array):
	var cur_target_id = 0
	
	for point in points:
		if cur_target_id == points.size() - 1:
			_on_unit_finished_move()
			return
		
		cur_move_point = points[cur_target_id + 1]
		
		cur_unit_object.unit_animator.play_anim(Globals.AnimationType.WALKING)
		var time_move = points[cur_target_id].distance_to(points[cur_target_id + 1]) / MOVING_SPEED
		
		tween_move.interpolate_property(
			cur_unit_object,
			"position",
			points[cur_target_id], 
			points[cur_target_id + 1],
			time_move
		)
		tween_move.start()
		
		cur_target_id += 1
		await tween_move.finished 


func _on_unit_finished_move():
	cur_unit_object.unit_animator.play_anim(Globals.AnimationType.IDLE)
	draw_line3d.clear()
	cur_move_point = Vector3.ZERO
	
	callable_finish_move.call()
