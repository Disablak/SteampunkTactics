extends Node


var units_controller: UnitsController
var units = {}
var cur_unit_id: int = -1
var player_units : PackedByteArray = PackedByteArray()
var enemy_units : PackedByteArray = PackedByteArray()


func get_cur_unit() -> Unit:
	if not units.has(cur_unit_id):
		printerr("Current unit not found!")
	
	return units[cur_unit_id]


func calc_units_team():
	for unit in units.values():
		if unit.unit_object.is_player_unit:
			player_units.push_back(unit.id)
		else:
			enemy_units.push_back(unit.id)

func get_enemy_units_ids() -> PackedByteArray:
	if get_cur_unit().unit_object.is_player_unit:
		return enemy_units
	else:
		return player_units
