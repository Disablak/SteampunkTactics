class_name Action
extends Resource


@export var considerations: Array[Consideration] = []

var time_points_price := 0
var score: float = 0.0


func pre_action():
	time_points_price = calc_time_points_price()


func execute_action():
	pass


func calc_time_points_price() -> int:
	return 9999


func is_enough_time_points_to_execute() -> bool:
	return TurnManager.can_spend_time_points(time_points_price)
