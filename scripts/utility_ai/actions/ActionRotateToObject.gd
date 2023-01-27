class_name ActionRotateToObject
extends Action


func execute_action():
	GlobalMap.ai_world.rotate_to_attention_dir()


func _to_string() -> String:
	return "ActionRotateToObject"
