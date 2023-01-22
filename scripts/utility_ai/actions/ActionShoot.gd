class_name ActionShoot
extends Action


func execute_action():
	GlobalMap.ai_world.cur_unit_shoot_to_visible_enemy()
	Globals.print_ai("Shoot")

