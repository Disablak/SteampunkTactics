class_name ActionShoot
extends Action


func execute_action():
	var enemy: Unit = GlobalUnits.units[0]
	print("shoot! to player")
	GlobalUnits.units_manager.shooting.shoot(GlobalUnits.get_cur_unit(), enemy)


func calc_time_points_price() -> int:
	return GlobalUnits.get_cur_unit().unit_data.weapon.shoot_price
