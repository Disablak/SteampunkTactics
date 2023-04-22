class_name ConsiderPathExist
extends Consideration


enum PathTarget {NONE, NEAR_ENEMY, PATRUL_ZONE, NEAR_COVER}
@export var path_target: PathTarget = PathTarget.NONE


func calc_score() -> float:
	return _get_score()


func _get_score() -> float:
	match path_target:
		PathTarget.NEAR_ENEMY:
			var path_data := ai_world.find_path_to_near_enemy()
			return 1.0 if path_data != null and path_data.path.size() != 0 else 0.0

		PathTarget.PATRUL_ZONE:
			if GlobalUnits.get_cur_unit().unit_data.ai_settings.patrul_zones_id_and_cells.is_empty():
				return 0.0

			var point := ai_world.find_path_to_patrul_zone()
			return 1.0 if point != Vector2i.ZERO else 0.0

		PathTarget.NEAR_COVER:
			var path_data = ai_world.get_cover_that_help()
			if path_data.path.size() == 0:
				return 0.0

			return _get_max_walk_cell() / (path_data.path.size() -1)

		_:
			printerr("Not setted path target")
			return 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderPathExist {0}".format([PathTarget.keys()[path_target]])


func _get_max_walk_cell() -> float:
	return float(floori(TurnManager.cur_time_points / GlobalUnits.get_cur_unit().unit_data.move_speed))
