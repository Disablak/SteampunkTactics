class_name ActionMoveToPatrulZone
extends Action


func execute_action():
	ai_world.walk_to_patrul_zone()


func _to_string() -> String:
	return "ActionMoveToPatrulZone"
