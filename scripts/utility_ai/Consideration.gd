class_name Consideration
extends Resource


@export var response_curve: Curve

var score: float = 0.0


func calc_score() -> float:
	return 0.0


func get_score() -> float:
	var raw_score := calc_score()
	score = clamp(response_curve.sample(raw_score) if response_curve != null else raw_score, 0.0, 1.0)
	return score
