class_name ConsiderEnoughAmmoToShoot
extends Consideration


func calc_score() -> float:
	var unit_data := GlobalUnits.get_cur_unit().unit_data

	return 1.0 if unit_data.is_enough_ammo() else 0.0
