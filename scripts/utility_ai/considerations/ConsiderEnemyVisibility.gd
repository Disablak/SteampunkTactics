class_name ConsiderEnemyVisibility
extends Consideration


func calc_score() -> float:
	var cur_unit : Unit = GlobalUnits.get_cur_unit()
	var visible_enemies = GlobalMap.ai_world.try_find_visible_enemy(cur_unit)

	return 1.0 if visible_enemies.size() > 0 else 0.0



func _to_string() -> String:
	return super._to_string() + "ConsiderEnemyVisibility"
