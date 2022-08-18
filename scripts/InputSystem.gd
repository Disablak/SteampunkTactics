extends Spatial


signal on_click_world(ray_cast_result, input_event)
signal on_unit_rotation_pressed(pos)
signal on_drag(dir)

onready var camera = get_parent().get_node("%Camera")

const ray_length = 1000

var dragging: bool
var drag_pos: Vector2
var prev_drag_pos: Vector2


func _input(event: InputEvent) -> void:
	_draging(event)
	
	if event is InputEventMouseButton and event.pressed:
		var ray_result = _make_ray(event.position)
		if ray_result:
			emit_signal("on_click_world", ray_result, event)
	
	if event.shift:
		var ray_result = _make_ray(get_viewport().get_mouse_position())
		if ray_result and ray_result.position != Vector3.ZERO:
			emit_signal("on_unit_rotation_pressed", ray_result.position)


func _draging(event: InputEvent):
	if event is InputEventMouseButton:
		dragging = event.pressed
		prev_drag_pos = event.position
	elif event is InputEventMouseMotion and dragging:
		drag_pos = (prev_drag_pos - event.position)
		prev_drag_pos = event.position
		emit_signal("on_drag", drag_pos)


func _make_ray(pos):
	var space_state = get_world().direct_space_state
	var from = camera.project_ray_origin(pos)
	var to = from + camera.project_ray_normal(pos) * ray_length
	var result = space_state.intersect_ray(from, to, [], 0x7FFFFFFF, true, true)
	return result
