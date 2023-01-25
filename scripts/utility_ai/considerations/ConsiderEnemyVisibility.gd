class_name ConsiderEnemyVisibility
extends Consideration


func calc_score() -> float:
	var cur_unit : Unit = GlobalUnits.get_cur_unit()
	var visible_enemies = GlobalMap.ai_world.get_visible_enemies()

	return 1.0 if visible_enemies.size() > 0 else 0.0



func _to_string() -> String:
	return super._to_string() + "ConsiderEnemyVisibility"
