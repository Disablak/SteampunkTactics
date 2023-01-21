class_name ActionMove
extends Action


func execute_action():
	GlobalMap.ai_world.walk_to_rand_cell()


func calc_time_points_price() -> int:
	return 100
