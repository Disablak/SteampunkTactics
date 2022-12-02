extends Node


var units_manager = null
var units = {}
var cur_unit_id: int = -1


func get_cur_unit() -> Unit:
	if not units.has(cur_unit_id):
		printerr("Current unit not found!")

	return units[cur_unit_id]


func get_units(enemies: bool) -> Array[Unit]:
	var result: Array[Unit]
	for unit in units.values():
		if unit.unit_data.unit_settings.is_enemy == enemies:
			result.push_back(unit)

	return result


func remove_unit(unit_id: int):
	if units.has(unit_id):
		units.erase(unit_id)
		print_debug("unit removed {0}".format([unit_id]))
	else:
		print_debug("unit {0} not exist".format([unit_id]))
