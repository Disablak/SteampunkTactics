class_name ConsiderInCover
extends Consideration


func calc_score() -> float:
	var cur_unit = GlobalUnits.get_cur_unit()
	var enemy_data_ai = cur_unit.unit_data.enemy_data_ai
	var in_cover : bool = enemy_data_ai.cur_cover_data != null and enemy_data_ai.cur_cover_data.count_covers_from_enemy > 0
	
	return 0.0 if in_cover else 1.0
