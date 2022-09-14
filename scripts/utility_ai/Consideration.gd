class_name Consideration
extends Resource


var score: float = 0.0 setget _set_score


func _set_score(new_score: float):
	score = clamp(new_score, 0.0, 1.0)


func calc_score() -> float:
	return 0.0
