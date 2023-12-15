extends Node


var unit_list: UnitList
var unit_order: UnitOrder
var unit_control: UnitControll


func get_unit(id: int) -> Unit:
	return unit_list.get_unit(id)
