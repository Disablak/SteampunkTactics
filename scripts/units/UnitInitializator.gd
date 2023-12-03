class_name UnitInitializator
extends Node


const UNIT_GROUP_NAME = "unit"


func create_units(unit_settings: Array[UnitSetting]) -> Array[Unit]:
	var units: Array[Unit]
	var all_unit_objects: Array[UnitObject] = _get_unit_objects()
	var unit_id = 0

	for unit_object in all_unit_objects:
		unit_object.unit_settings = _get_unit_setting(unit_settings, unit_object.unit_name, unit_object)
		var new_unit: Unit = Unit.new(unit_id, UnitData.new(unit_object.unit_settings), unit_object)

		units.append(new_unit)
		unit_id += 1

	return units


func _get_unit_objects() -> Array[UnitObject]:
	var all_units = get_tree().get_nodes_in_group(UNIT_GROUP_NAME)
	var all_unit_objects: Array[UnitObject]
	all_unit_objects.assign(all_units)

	return all_unit_objects


func _get_unit_setting(unit_settings: Array[UnitSetting], unit_name: String, unit_object: UnitObject) -> UnitSetting:
	var unit_setting := _get_unit_setting_by_name(unit_settings, unit_name)
	var use_settings_from_unit_objects = not unit_setting
	if use_settings_from_unit_objects:
		unit_setting = unit_object.unit_settings_resource.get_object()

	return unit_setting


func _get_unit_setting_by_name(unit_settings: Array[UnitSetting], unit_name: String) -> UnitSetting:
	for unit in unit_settings:
		if unit.unit_name == unit_name:
			return unit;

	return null;
