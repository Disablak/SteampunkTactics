class_name ConsiderAmmo
extends Consideration


func calc_score() -> float:
	var cur_unit_data := GlobalUnits.get_cur_unit().unit_data
	var result: float = 1.0 - float(cur_unit_data.cur_weapon_ammo) / float(cur_unit_data.weapon.ammo)
	print("ammo result {0}".format([result]))
	return result
