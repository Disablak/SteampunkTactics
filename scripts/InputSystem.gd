class_name InputSystem
extends Node2D


signal on_mouse_hover(mouse_pos: Vector2)
signal on_pressed_lmc(mouse_pos: Vector2)
signal on_pressed_rmc(mouse_pos: Vector2)
signal on_pressed_esc()
signal on_drag(dir: Vector2)

const TIME_CLICK_MS = 200

var dragging: bool
var drag_pos: Vector2
var prev_drag_pos: Vector2
var prev_hover_pos: Vector3

var was_mouse_btn_pressed: bool = false
var time_pressed: int


func _unhandled_input(event: InputEvent) -> void:
	if _draging(event):
		return

	_mouse_hover(event)
	_mouse_click(event)
	_other_inputs(event)


func _draging(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		dragging = event.pressed
		prev_drag_pos = event.position
		return false

	elif event is InputEventMouseMotion and dragging:
		drag_pos = (prev_drag_pos - event.position)
		prev_drag_pos = event.position

		on_drag.emit(drag_pos)
		return true

	return false


func _mouse_click(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if was_mouse_btn_pressed && not event.pressed:
			var time_released = Time.get_ticks_msec()
			if time_released - time_pressed > TIME_CLICK_MS:
				return

			was_mouse_btn_pressed = false

			on_pressed_lmc.emit(event.position)
			#on_pressed_lmc.emit(formatted_position(event.position))
			return

		if event.pressed:
			was_mouse_btn_pressed = true
			time_pressed = Time.get_ticks_msec()
			return


func _mouse_hover(event: InputEvent):
	if not (event is InputEventMouseMotion):
		return

	on_mouse_hover.emit(event.position)


func _other_inputs(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		on_pressed_esc.emit()

	if event.is_action_pressed("right_click"):
		on_pressed_rmc.emit(event.position)

	if event.is_action_pressed("cheat hide fog"):
		Globals.DEBUG_HIDE_FOG = not Globals.DEBUG_HIDE_FOG
		GlobalsUi.message("cheat DEBUG_HIDE_FOG activated {0}".format([Globals.DEBUG_HIDE_FOG]))

	if event.is_action_pressed("cheat show enemy always"):
		Globals.DEBUG_SHOW_ENEMY_ALWAYS = not Globals.DEBUG_SHOW_ENEMY_ALWAYS
		GlobalsUi.message("cheat DEBUG_SHOW_ENEMY_ALWAYS activated {0}".format([Globals.DEBUG_SHOW_ENEMY_ALWAYS]))

