extends Node


var max_time_points := 100
var cur_time_points := 100

enum TypeSpendAction{
	NONE,
	RESTORE_TURN,
	SHOOTING,
	RELOADING,
	WALKING
}


func can_spend_time_points(spend_points: int) -> bool:
	var enough = cur_time_points >= spend_points
	#if not enough:
	#	print("Not enough time points {0}".format([spend_points]))

	return enough


func spend_time_points(type_spend_action: TypeSpendAction, spend_points: int):
	_set_time_points(type_spend_action, cur_time_points - spend_points)


func restore_time_points():
	_set_time_points(TypeSpendAction.RESTORE_TURN, max_time_points)


func show_hint_spend_points(spend_points: int):
	GlobalBus.on_hint_time_points.emit(cur_time_points - spend_points, max_time_points)


func _set_time_points(type_spend_action: TypeSpendAction, value: int):
	cur_time_points = value
	GlobalBus.on_changed_time_points.emit(type_spend_action, cur_time_points, max_time_points)
	GlobalBus.on_hint_time_points.emit(cur_time_points, max_time_points)
