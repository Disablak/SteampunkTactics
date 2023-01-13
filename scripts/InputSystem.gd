class_name InputSystem
extends Node2D


signal on_mouse_hover(mouse_pos: Vector2)
signal on_mouse_click(mouse_pos: Vector2)
signal on_drag(dir)
signal on_pressed_esc()

@onready var camera_controller := get_node("CameraController") as CameraController
@onready var camera := get_node("CameraController/Camera2d") as Camera2D
@onready var camera_bounds: Node2D = get_node("CameraBounds") as Node2D

const TIME_CLICK_MS = 200

var dragging: bool
var drag_pos: Vector2
var prev_drag_pos: Vector2
var prev_hover_pos: Vector3

var was_mouse_btn_pressed: bool = false
var time_pressed: int


func _ready() -> void:
	GlobalsUi.input_system = self


func _unhandled_input(event: InputEvent) -> void:
	if _draging(event):
		return

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

		camera_controller.drag(drag_pos)
		emit_signal("on_drag", drag_pos)
		return true

	return false


func _mouse_click(event: InputEvent):
	if event is InputEventMouseButton:
		if was_mouse_btn_pressed && not event.pressed:
			var time_released = Time.get_ticks_msec()
			if time_released - time_pressed > TIME_CLICK_MS:
				return

			was_mouse_btn_pressed = false

			on_mouse_click.emit(formatted_position(event.position))
			return

		if event.pressed:
			was_mouse_btn_pressed = true
			time_pressed = Time.get_ticks_msec()
			return


func _mouse_hover(event: InputEvent):
	if not (event is InputEventMouseMotion):
		return

	on_mouse_hover.emit(formatted_position(event.position))


func _click_escape(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		on_pressed_esc.emit()


func formatted_position(position: Vector2) -> Vector2:
	var view_size := camera.get_viewport_rect().size
	var camera_offset = camera_controller.position - (view_size / 2)
	var camera_zoomed_pos = ((view_size / 2) - ((view_size / camera.zoom) / 2))
	return camera_zoomed_pos + camera_offset + position / camera.zoom
