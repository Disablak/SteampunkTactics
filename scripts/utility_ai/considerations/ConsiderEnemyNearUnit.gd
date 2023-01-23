class_name ConsiderEnemyNearUnit
extends Consideration


func calc_score() -> float:
	return 1.0 if ai_world.is_any_enemy_near_unit() else 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderEnemyNearUnit"
