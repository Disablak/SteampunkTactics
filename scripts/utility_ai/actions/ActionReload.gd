class_name ActionReload
extends Action


func execute_action():
	GlobalMap.ai_world.reload()


func _to_string() -> String:
	return "ActionReload"
