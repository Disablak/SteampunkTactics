class_name MiniGame
extends Node2D


signal on_started(trigger_zone_pos: float, trigger_zone_width: float)
signal on_changed_value(value: float)
signal on_triggered(success: bool)


@export var key_to_trigger: Key
@export var trigger_zone_pos: float = 0.7
@export var trigger_zone_width: float = 0.2
@export var speed: float = 1.0
@export var trash_hold: float = 0.05
@export var curve: Curve

var _cur_time: float = 0.0
var _cur_value: float
var _is_started: bool = false


func start():
	visible = true

	_is_started = true
	on_started.emit(trigger_zone_pos, trigger_zone_width)


func _trigger():
	visible = false

	_is_started = false

	var min_trigger = clampf(trigger_zone_pos - trash_hold, 0.0, 1.0)
	var max_trigger = clampf(trigger_zone_pos + trigger_zone_width + trash_hold, 0.0, 1.0)

	var is_hit: bool = _cur_value > min_trigger and _cur_value < max_trigger
	on_triggered.emit(is_hit)


func _process(delta: float) -> void:
	if not _is_started:
		return

	_cur_time += speed * delta
	_cur_value = curve.sample(pingpong(_cur_time, 1.0))

	on_changed_value.emit(_cur_value)


func _input(event: InputEvent) -> void:
	if not _is_started:
		return

	if event is InputEventKey:
		if event.keycode == key_to_trigger and event.is_pressed():
			_trigger()
