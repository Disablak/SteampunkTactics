class_name Consideration
extends Resource


@export var response_curve: Curve

var score: float = 0.0


func calc_score() -> float:
	return 0.0
	

func get_score() -> float:
	score = clamp(response_curve.sample(calc_score()), 0.0, 1.0) 
	print("consideration result {0}".format([score]))
	return score
