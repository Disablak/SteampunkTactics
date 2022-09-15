class_name ConsiderTimePoints
extends Consideration


func calc_score() -> float:
	var result = float(TurnManager.cur_time_points) / float(TurnManager.max_time_points)
	print("time points {0}".format([result]))
	return result
