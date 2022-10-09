class_name ConsiderEnoughReloadTP
extends Consideration


func calc_score() -> float:
	var reload_price = GlobalUnits.get_cur_unit().unit_data.weapon.reload_price
	
	return 1.0 if TurnManager.can_spend_time_points(reload_price) else 0.0
