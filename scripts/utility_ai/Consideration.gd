class_name Consideration
extends Resource


@export var invert: bool = false
@export var response_curve: Curve

var ai_world: AiWorld:
	get: return GlobalMap.ai_world

var score: float = 0.0


func calc_score() -> float:
	return 0.0


func get_score() -> float:
	var calced_score = clampf(calc_score(), 0.0, 1.0)
	var raw_score := 1.0 - calced_score if invert else calced_score

	score = response_curve.sample(raw_score) if response_curve != null else raw_score
	return score
