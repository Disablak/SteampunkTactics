extends Node3D


signal on_click_world(ray_cast_result, input_event)
signal on_unit_rotation_pressed(pos)
signal on_drag(dir)
signal on_mouse_hover(hover_info)

@onready var camera = get_node("%Camera3D")
@onready var hover_info = HoverInfo.new()

const ray_length = 1000

var dragging: bool
var drag_pos: Vector2
var prev_drag_pos: Vector2
var prev_hover_pos: Vector3


class HoverInfo:
	var pos
	var hover_type
	var unit_id
	
	func set_info(pos, hover_type, unit_id = -1) -> RefCounted:
		self.pos = pos
		self.hover_type = hover_type
		self.unit_id = unit_id
		
		return self


func _input(event: InputEvent) -> void:
	if _draging(event):
		return

	_press_shift(event)
	_mouse_click(event)
	_mouse_hover(event)


func _draging(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		dragging = event.pressed
		prev_drag_pos = event.position
		return false
		
	elif event is InputEventMouseMotion and dragging:
		drag_pos = (prev_drag_pos - event.position)
		prev_drag_pos = event.position
		emit_signal("on_drag", drag_pos)
		return true
		
	return false


func _mouse_click(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		var ray_result = _make_ray(event.position)
		if ray_result:
			emit_signal("on_click_world", ray_result, event)


func _press_shift(event: InputEvent) -> bool:
	if event is InputEventMouseMotion:
		var ray_result = _make_ray(get_viewport().get_mouse_position())
		if ray_result and ray_result.position != Vector3.ZERO:
			emit_signal("on_unit_rotation_pressed", ray_result.position)
			return true
	
	return false


func _mouse_hover(event: InputEvent):
	if not (event is InputEventMouseMotion):
		return
	
	var ray_result = _make_ray(get_viewport().get_mouse_position())
	if not ray_result:
		emit_signal("on_mouse_hover", hover_info.set_info(Vector3.ZERO, Globals.MouseHoverType.NONE))
		return
	
	if ray_result.collider.is_in_group("pathable"):
		var pos = ray_result.position
		if pos != prev_hover_pos:
			emit_signal("on_mouse_hover", hover_info.set_info(pos, Globals.MouseHoverType.GROUND))
			prev_hover_pos = pos
			return
	
	var unit_object: UnitObject = ray_result.collider.get_parent() as UnitObject
	if not unit_object:
		return
		
	emit_signal("on_mouse_hover", hover_info.set_info(unit_object.global_transform.origin, Globals.MouseHoverType.UNIT, unit_object.unit_id))


func _make_ray(pos):
	var space_state = get_world_3d().direct_space_state
	var from = camera.project_ray_origin(pos)
	var to = from + camera.project_ray_normal(pos) * ray_length
	var ray_query_params := PhysicsRayQueryParameters3D.create(from, to, 0x7FFFFFFF)
	ray_query_params.collide_with_areas = true
	ray_query_params.collide_with_bodies = true
	
	var result = space_state.intersect_ray(ray_query_params)
	return result
