class_name ConsiderCanKickNearEnemy
extends Consideration


func calc_score() -> float:
	return 1.0 if ai_world.can_kick_any_near_enemy() else 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderCanKickNearEnemy"
