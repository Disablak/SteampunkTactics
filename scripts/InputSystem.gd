extends Spatial


signal on_click_world(ray_cast_result, input_event)
signal on_unit_rotation_pressed(pos)
signal on_drag(dir)
signal on_mouse_hover_cell(is_hover, cell_pos)

onready var camera = get_parent().get_node("%Camera")

const ray_length = 1000

var dragging: bool
var drag_pos: Vector2
var prev_drag_pos: Vector2
var prev_hover_pos: Vector3


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
	if event is InputEventMouseMotion:
		var ray_result = _make_ray(get_viewport().get_mouse_position())
		if ray_result and ray_result.collider.is_in_group("pathable"):
			var pos = ray_result.position
			if pos != prev_hover_pos:
				emit_signal("on_mouse_hover_cell", true, ray_result.position)
				prev_hover_pos = pos
		else:
			emit_signal("on_mouse_hover_cell", false, Vector3.ZERO)


func _make_ray(pos):
	var space_state = get_world().direct_space_state
	var from = camera.project_ray_origin(pos)
	var to = from + camera.project_ray_normal(pos) * ray_length
	var result = space_state.intersect_ray(from, to, [], 0x7FFFFFFF, true, true)
	return result
