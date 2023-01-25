class_name ConsiderLowAmmo
extends Consideration


func calc_score() -> float:
	var cur_unit_data := GlobalUnits.get_cur_unit().unit_data
	var result: float = 1.0 - float(cur_unit_data.riffle.cur_weapon_ammo) / float(cur_unit_data.riffle.settings.max_ammo)
	return result


func _to_string() -> String:
	return super._to_string() + "ConsiderLowAmmo"
