class_name ActionMove
extends Action


func execute_action():
	GlobalMap.ai_world.walk_to_rand_cell()


func _to_string() -> String:
	return "ActionMove"
