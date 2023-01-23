class_name ActionMoveToEnemy
extends Action


func execute_action():
	ai_world.walk_to_near_enemy()

func _to_string() -> String:
	return "ActionMoveToEnemy"
