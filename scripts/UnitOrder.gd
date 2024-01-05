class_name UnitOrder
extends Node


@export var battle_states: BattleStates


var ordered_unit_ids: Array[int] = []
var cur_unit_idx: int = 0


func init(units: Array[Unit]):
	_set_units_order(units)
	_emit_unit_change_control()


func deinit():
	ordered_unit_ids.clear()
	cur_unit_idx = 0


func _enter_tree() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)


func _on_unit_died(unit_id: int, unit_id_killer: int):
	remove_unit_from_order(unit_id)


func _set_units_order(units: Array[Unit]):
	var ordered_units = Array(units)
	ordered_units.sort_custom(func(a: Unit, b: Unit): return a.unit_data.initiative > b.unit_data.initiative)

	ordered_unit_ids.clear()
	for unit in ordered_units:
		ordered_unit_ids.append(unit.id)

	cur_unit_idx = 0


func get_cur_unit_id() -> int:
	if ordered_unit_ids.size() == 0:
		return -1

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


func next_unit_turn():
	if battle_states.is_game_over:
		return

	set_next_unit_id()
	_emit_unit_change_control()


func _emit_unit_change_control():
	var unit_id = get_cur_unit_id()
	GlobalBus.on_unit_changed_control.emit(unit_id, false)


func _is_game_over() -> bool:
	var all_player_units := GlobalUnits.unit_list.get_team_units(false)
	var all_enemy_units := GlobalUnits.unit_list.get_team_units(true)

	return all_player_units.size() == 0 or all_enemy_units.size() == 0
