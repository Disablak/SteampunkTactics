class_name ActionMove
extends Action


func execute_action():
	GlobalMap.ai_world.walk_to_rand_cell()
	Globals.print_ai("Moving")

