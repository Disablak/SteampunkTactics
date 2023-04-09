extends Node


var units_manager: UnitsManager = null
var units = {}
var cur_unit_id: int = -1

var cur_unit_is_enemy: bool:
	get:
		var unit = get_cur_unit()
		return unit and unit.unit_data.is_enemy


func get_cur_unit() -> Unit:
	if not units.has(cur_unit_id):
		printerr("Current unit not found!")
		return null

	return units[cur_unit_id]


func get_units(enemies: bool) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units.values():
		if unit.unit_data.is_enemy == enemies:
			result.push_back(unit)

	return result


func get_enemies_in_range(unit: Unit) -> Array[Unit]:
	var result: Array[Unit]
	for enemy in GlobalUnits.get_units(not unit.unit_data.is_enemy):
		var distance = unit.unit_object.visual_pos.distance_to(enemy.unit_object.visual_pos) / Globals.CELL_SIZE
		if distance <= enemy.unit_data.unit_settings.range_of_view:
			result.append(enemy)

	return result


func remove_unit(unit_id: int):
	if units.has(unit_id):
		units.erase(unit_id)
		print_debug("unit removed {0}".format([unit_id]))
	else:
		print_debug("unit {0} not exist".format([unit_id]))
