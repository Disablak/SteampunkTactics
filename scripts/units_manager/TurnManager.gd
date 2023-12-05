extends Node

const MIN_PRICE_TO_MOVE = 10

var max_time_points := 100
var cur_time_points := 100


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed_control)


func _on_unit_changed_control(unit_id: int, instantly: bool):
	restore_time_points()


func can_spend_time_points(spend_points: int) -> bool:
	var enough = cur_time_points >= spend_points
	return enough

func enough_time_points_for_start_move() -> bool:
	return cur_time_points >= MIN_PRICE_TO_MOVE


func spend_time_points(spend_points: int):
	_set_time_points(cur_time_points - spend_points)


func restore_time_points():
	_set_time_points(max_time_points)


func show_hint_spend_points(spend_points: int):
	GlobalBus.on_hint_time_points.emit(cur_time_points - spend_points, max_time_points)


func _set_time_points(value: int):
	cur_time_points = value
	GlobalBus.on_changed_time_points.emit(cur_time_points, max_time_points)
