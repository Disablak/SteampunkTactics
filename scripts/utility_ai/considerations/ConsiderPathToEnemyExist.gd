class_name ConsiderPathToEnemyExist
extends Consideration


func calc_score() -> float:
	var path := ai_world.find_path_to_near_enemy()

	if path.size() == 0:
		return 0.0

	var max_length_to_walk := TurnManager.cur_time_points / GlobalUnits.get_cur_unit().unit_data.unit_settings.walk_speed
	return float(max_length_to_walk) / path.size()


func _to_string() -> String:
	return super._to_string() + "ConsiderPathToEnemyExist"
