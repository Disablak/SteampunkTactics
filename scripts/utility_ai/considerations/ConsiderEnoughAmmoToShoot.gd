class_name ConsiderEnoughAmmoToShoot
extends Consideration


func calc_score() -> float:
	var unit_data := GlobalUnits.get_cur_unit().unit_data

	return 1.0 if unit_data.unit_settings.riffle.is_enough_ammo() else 0.0



func _to_string() -> String:
	return super._to_string() + "ConsiderEnoughAmmoToShoot"
