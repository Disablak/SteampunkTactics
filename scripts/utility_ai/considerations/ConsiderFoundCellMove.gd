class_name ConsiderFoundCellMove
extends Consideration


func calc_score() -> float:
	var move_price = GlobalMap.ai_world.find_walk_cell_and_get_price()
	return 1.0 if TurnManager.can_spend_time_points(move_price) else 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderFoundCellMove"
