class_name ActionNextTurn
extends Action


func execute_action():
	GlobalMap.ai_world.next_turn()


func _to_string() -> String:
	return "ActionNextTurn"
