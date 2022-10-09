class_name ConsiderEnoughShootTP
extends Consideration


func calc_score() -> float:
	var shoot_price = GlobalUnits.get_cur_unit().unit_data.weapon.shoot_price
	
	return 1.0 if TurnManager.can_spend_time_points(shoot_price) else 0.0
