class_name ActionKickEnemy
extends Action


func execute_action():
	ai_world.kick_near_enemy()


func _to_string() -> String:
	return "ActionKickEnemy"
