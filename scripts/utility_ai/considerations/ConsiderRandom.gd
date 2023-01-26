class_name ConsiderRandom
extends Consideration


func calc_score() -> float:
	return randf()


func _to_string() -> String:
	return super._to_string() + "ConsiderRandom"

