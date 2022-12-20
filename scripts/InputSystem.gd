extends Node2D


signal on_mouse_hover(cell_info: CellInfo)
signal on_mouse_click(cell_info: CellInfo)
signal on_drag(dir)
signal on_pressed_esc()

@export var drag_sensitive = 0.5

@onready var camera_controller := get_node("CameraController")
@onready var camera := get_node("CameraController/Camera2d") as Camera2D
@onready var camera_bounds: Node2D = get_node("CameraBounds") as Node2D

@onready var cell_info: = CellInfo.new()

const TIME_CLICK_MS = 150

var dragging: bool
var drag_pos: Vector2
var prev_drag_pos: Vector2
var prev_hover_pos: Vector3

var was_mouse_btn_pressed: bool = false
var time_pressed: int

var camera_bound_rect: Rect2


func _ready() -> void:
	camera_bound_rect = Rect2(camera_bounds.position, camera_bounds.scale * Globals.CELL_SIZE)


func _input(event: InputEvent) -> void:
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

		_drag(drag_pos)
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

			cell_info.reset()
			cell_info.cell_pos = formatted_position(event.position)
			on_mouse_click.emit(cell_info)
			return

		if event.pressed:
			was_mouse_btn_pressed = true
			time_pressed = Time.get_ticks_msec()
			return


func _mouse_hover(event: InputEvent):
	if not (event is InputEventMouseMotion):
		return

	cell_info.reset()
	cell_info.cell_pos = formatted_position(event.position)
	on_mouse_hover.emit(cell_info)


func _click_escape(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		on_pressed_esc.emit()


func _drag(dir: Vector2) -> void:
	var half_bound_size := camera_bound_rect.size / 2
	var half_camera_size := get_viewport_rect().size / camera.zoom / 2

	var min_x = -half_bound_size.x + camera_bound_rect.position.x + half_camera_size.x
	var max_x =  half_bound_size.x + camera_bound_rect.position.x - half_camera_size.x
	var min_y = -half_bound_size.y + camera_bound_rect.position.y + half_camera_size.y
	var max_y =  half_bound_size.y + camera_bound_rect.position.y - half_camera_size.y

	var new_pos = camera_controller.position + dir * drag_sensitive
	camera_controller.position = Vector2(clampf(new_pos.x, min_x, max_x), clampf(new_pos.y, min_y, max_y))


func formatted_position(position: Vector2) -> Vector2:
	var view_size := camera.get_viewport_rect().size
	var camera_offset = camera_controller.position - (view_size / 2)
	var camera_zoomed_pos = ((view_size / 2) - ((view_size / camera.zoom) / 2))
	return camera_zoomed_pos + camera_offset + position / camera.zoom
