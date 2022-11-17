class_name ActionShoot
extends Action


func execute_action():
	GlobalMap.world.shoot_to_player()


func calc_time_points_price() -> int:
	return GlobalUnits.get_cur_unit().unit_data.weapon.shoot_price
