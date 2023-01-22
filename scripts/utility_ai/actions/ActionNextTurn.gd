class_name ActionNextTurn
extends Action


func execute_action():
	GlobalMap.ai_world.next_turn()
	Globals.print_ai("Next turn")

