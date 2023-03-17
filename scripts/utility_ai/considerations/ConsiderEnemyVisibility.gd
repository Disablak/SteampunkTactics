class_name ConsiderEnemyVisibility
extends Consideration


func calc_score() -> float:
	var visible_enemies: = ai_world.get_visible_enemies()
	return 1.0 if visible_enemies.size() > 0 else 0.0



func _to_string() -> String:
	return super._to_string() + "ConsiderEnemyVisibility"
