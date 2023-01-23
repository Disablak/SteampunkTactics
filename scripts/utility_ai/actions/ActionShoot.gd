class_name ActionShoot
extends Action


func execute_action():
	GlobalMap.ai_world.cur_unit_shoot_to_visible_enemy()


func _to_string() -> String:
	return "ActionShoot"
