class_name ActionKickEnemy
extends Action


func execute_action():
	ai_world.kick_near_enemy()
	Globals.print_ai("Kick Enemy")
