class_name ConsiderNearCover
extends Consideration


@export var max_distance := 10.0


func calc_score() -> float:
	var cur_unit_pos : Vector3 = GlobalUnits.get_cur_unit().unit_object.global_position
	var nearest_cover_pos : Vector3 = GlobalMap.world.find_nearest_cover(cur_unit_pos)
	var distance = cur_unit_pos.distance_to(nearest_cover_pos)

	if nearest_cover_pos == Vector3.ZERO or distance >= max_distance:
		distance = max_distance

	print("Nearest coved distance = {0}, {1}".format([distance, distance / max_distance]))
	return distance / max_distance
