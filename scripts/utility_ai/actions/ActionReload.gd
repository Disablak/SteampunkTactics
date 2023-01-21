class_name ActionReload
extends Action


func execute_action():
	GlobalUnits.units_manager.shooting.reload()


func calc_time_points_price() -> int:
	return GlobalUnits.get_cur_unit().unit_data.unit_settings.riffle.reload_price
