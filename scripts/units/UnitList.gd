class_name UnitList
extends Node


@export var unit_order: UnitOrder

var _units = {} # id to unit


func _enter_tree() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)


func get_cur_unit_id() -> int:
	return unit_order.get_cur_unit_id()


func get_cur_unit() -> Unit:
	var cur_unit_id := get_cur_unit_id()
	return _units[cur_unit_id]


func get_unit(unit_id: int) -> Unit:
	return _units[unit_id]


func is_unit_exist(unit_id: int) -> bool:
	return _units.has(unit_id)


func get_all_units() -> Array[Unit]:
	return _units.values()


func get_team_units(enemies: bool) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit: Unit in _units.values():
		if unit.unit_data.is_enemy == enemies:
			result.push_back(unit)

	return result


func add_units(units: Array[Unit]):
	for unit: Unit in units:
		add_unit(unit)


func add_unit(unit: Unit):
	_units[unit.id] = unit


func remove_unit(unit_id: int):
	if _units.has(unit_id):
		_units.erase(unit_id)


func _on_unit_died(unit_id, unit_id_killer):
	remove_unit(unit_id)
	unit_order.remove_unit_from_order(unit_id)
