class_name ActionShoot
extends Action


func execute_action():
	GlobalMap.ai_world.shoot_in_random_enemy()


func _to_string() -> String:
	return "ActionShoot"
