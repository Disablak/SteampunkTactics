class_name ActionMoveToCover
extends Action


func execute_action():
	ai_world.move_to_cover()


func _to_string() -> String:
	return "ActionMoveToCover"
