extends Node2D


signal on_mouse_hover(hover_info: HoverInfo)
signal on_mouse_click(hover_info: HoverInfo)
signal on_drag(dir)

@onready var camera = get_node("%Camera3D")
@onready var hover_info = HoverInfo.new()

const ray_length = 1000

var dragging: bool
var drag_pos: Vector2
var prev_drag_pos: Vector2
var prev_hover_pos: Vector3


class HoverInfo:
	var pos: Vector2
	var cell_obj: CellObject
	var unit_id: int
	
	func reset():
		pos = Vector2.ZERO
		cell_obj = null
		unit_id = -1


func _input(event: InputEvent) -> void:
#	if _draging(event):
#		return

	_mouse_hover(event)
	_mouse_click(event)
	#_press_shift(event)


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
		hover_info.reset()
		hover_info.pos = event.position
		on_mouse_click.emit(hover_info)

#
#func _press_shift(event: InputEvent) -> bool:
#	if event is InputEventMouseMotion:
#		var ray_result = _make_ray(get_viewport().get_mouse_position())
#		if ray_result and ray_result.position != Vector3.ZERO:
#			emit_signal("on_unit_rotation_pressed", ray_result.position)
#			return true
#
#	return false
#
#
func _mouse_hover(event: InputEvent):
	if not (event is InputEventMouseMotion):
		return
	
	hover_info.reset()
	hover_info.pos = event.position
	on_mouse_hover.emit(hover_info)
