class_name ActionShoot
extends Action


func execute_action():
	var player: UnitObject = GlobalUnits.units[0].unit_object
	GlobalUnits.units_controller.shooting_module.shoot(player)


func calc_time_points_price() -> int:
	return GlobalUnits.get_cur_unit().unit_data.weapon.shoot_price
