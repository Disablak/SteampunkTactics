class_name ActionMoveToEnemy
extends Action


func execute_action():
	ai_world.walk_to_near_enemy()
	Globals.print_ai("Walking to near enemy")
