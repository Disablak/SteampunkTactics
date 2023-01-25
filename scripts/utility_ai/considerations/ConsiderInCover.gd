class_name ConsiderInCover
extends Consideration


func calc_score() -> float:
	return 1.0 if ai_world.is_unit_in_cover() else 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderInCover"
