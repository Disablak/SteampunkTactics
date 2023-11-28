class_name UnitOrder
extends Node


const UNIT_GROUP_NAME = "unit"

@export var main_hero_start_setting: UnitSettingsResource

var units: Array[Unit]
var ordered_unit_ids: Array[int] = []
var cur_unit_idx: int = 0


func _ready() -> void:
	init([main_hero_start_setting.get_object()])


func init(unit_settings: Array[UnitSetting]):
	_init_units(unit_settings)
	_set_units_order()


func _init_units(unit_settings: Array[UnitSetting]):
	var all_unit_objects: Array[UnitObject] = _get_unit_objects()
	var unit_id = 0

	for unit_object in all_unit_objects:
		unit_object.unit_settings = _get_unit_setting(unit_settings, unit_object.unit_name, unit_object)
		var new_unit: Unit = Unit.new(unit_id, UnitData.new(unit_object.unit_settings, unit_object.ai_settings), unit_object)

		units.append(new_unit)
		GlobalUnits.units[unit_id] = new_unit

		unit_id += 1


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


func _set_units_order():
	var ordered_units = Array(units)
	ordered_units.sort_custom(func(a: Unit, b: Unit): return a.unit_data.initiative > b.unit_data.initiative)

	ordered_unit_ids.clear()
	for unit in ordered_units:
		ordered_unit_ids.append(unit.id)

	cur_unit_idx = 0


func get_cur_unit_id() -> int:
	return ordered_unit_ids[clamp(cur_unit_idx, 0, ordered_unit_ids.size() - 1)]


func set_next_unit_id():
	cur_unit_idx += 1
	if cur_unit_idx > ordered_unit_ids.size() - 1:
		cur_unit_idx = 0


func get_prev_unit_id() -> int:
	var prev_unit_idx = ordered_unit_ids[wrapi(cur_unit_idx - 1, 0, ordered_unit_ids.size() - 1)]
	return prev_unit_idx


func remove_unit_from_order(unit_id: int):
	ordered_unit_ids.erase(unit_id)
