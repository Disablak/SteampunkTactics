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
