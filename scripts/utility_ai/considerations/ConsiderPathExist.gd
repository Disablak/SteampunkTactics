class_name ConsiderPathExist
extends Consideration


enum PathTarget {NONE, NEAR_ENEMY, PATRUL_ZONE}
@export var path_target: PathTarget = PathTarget.NONE


func calc_score() -> float:
	return _get_score()


func _get_score() -> float:
	match path_target:
		PathTarget.NEAR_ENEMY:
			var path := ai_world.find_path_to_near_enemy()
			if path.size() == 0:
				return 0.0

			var max_length_to_walk := TurnManager.cur_time_points / GlobalUnits.get_cur_unit().unit_data.unit_settings.walk_speed
			return float(max_length_to_walk) / path.size()

		PathTarget.PATRUL_ZONE:
			var point := ai_world.find_path_to_patrul_zone()
			return 1.0 if point != Vector2i.ZERO else 0.0

		_:
			printerr("Not setted path target")
			return 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderPathExist {0}".format([PathTarget.keys()[path_target]])
