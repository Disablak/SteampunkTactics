extends Node


var units = {}
var cur_unit_id: int = -1


func get_cur_unit() -> Unit:
	if not units.has(cur_unit_id):
		printerr("Current unit not found!")
	
	return units[cur_unit_id]

