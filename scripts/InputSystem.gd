extends Node2D


signal on_mouse_hover(cell_info: CellInfo)
signal on_mouse_click(cell_info: CellInfo)
signal on_drag(dir)
signal on_pressed_esc()

@onready var camera_controller := get_node("CameraController")
@onready var camera := get_node("CameraController/Camera2d") as Camera2D
@onready var cell_info: = CellInfo.new()

const ray_length = 1000

var dragging: bool
var drag_pos: Vector2
var prev_drag_pos: Vector2
var prev_hover_pos: Vector3


func _input(event: InputEvent) -> void:
#	if _draging(event):
#		return

	_mouse_hover(event)
	_mouse_click(event)
	_click_escape(event)


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
		cell_info.reset()
		cell_info.cell_pos = formatted_position(event.position)
		on_mouse_click.emit(cell_info)


func _mouse_hover(event: InputEvent):
	if not (event is InputEventMouseMotion):
		return

	cell_info.reset()
	cell_info.cell_pos = formatted_position(event.position)
	on_mouse_hover.emit(cell_info)


func _click_escape(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		on_pressed_esc.emit()


func formatted_position(position: Vector2) -> Vector2:
	var view_size := camera.get_viewport_rect().size
	var camera_offset = camera_controller.position - (view_size / 2)
	var camera_zoomed_pos = ((view_size / 2) - ((view_size / camera.zoom) / 2))
	return camera_zoomed_pos + camera_offset + position / camera.zoom
