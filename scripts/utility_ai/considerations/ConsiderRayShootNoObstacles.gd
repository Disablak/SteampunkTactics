class_name ConsiderRayShootNoObstacles
extends Consideration


func calc_score() -> float:
	var shootable_enemies = ai_world.get_shootable_enemies()
	return 1.0 if shootable_enemies.size() > 0 else 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderRayShootNoObstacles"
