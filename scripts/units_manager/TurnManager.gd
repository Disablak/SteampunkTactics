extends Node


enum TypeSpendAction{
	NONE,
	RESTORE_TURN,
	SHOOTING,
	RELOADING,
	WALKING,
	MELLE_ATTACK,
	THROW_GRENADE,
	OPEN_DOOR,
	PUSH
}

var order_unit_id: Array[int] = []
var cur_unit_idx: int = 0

var max_time_points := 100
var cur_time_points := 100


func set_units_order(units: Array):
	var ordered_units = Array(units)
	ordered_units.sort_custom(func(a: Unit, b: Unit): return a.unit_data.initiative > b.unit_data.initiative)

	order_unit_id.clear()
	for unit in ordered_units:
		order_unit_id.append(unit.id)

	cur_unit_idx = 0


func get_cur_turn_unit_id() -> int:
	return order_unit_id[clamp(cur_unit_idx, 0, order_unit_id.size() - 1)]


func get_next_unit_id() -> int:
	cur_unit_idx += 1
	if cur_unit_idx > order_unit_id.size() - 1:
		cur_unit_idx = 0

	return get_cur_turn_unit_id()


func get_prev_unit_id() -> int:
	var prev_unit_idx = order_unit_id[wrapi(cur_unit_idx - 1, 0, order_unit_id.size() - 1)]
	return prev_unit_idx


func remove_unit_from_order(unit_id: int):
	order_unit_id.erase(unit_id)


func check_is_game_over() -> bool:
	var winner_team: int = 0
	for unit_id in order_unit_id:
		if not GlobalUnits.units.has(unit_id):
			continue

		var unit: Unit = GlobalUnits.units[unit_id]
		var team_code: int = -1 if unit.unit_data.is_enemy else 1
		if winner_team == 0:
			winner_team = team_code
		elif winner_team != team_code:
			return false

	return true


func can_spend_time_points(spend_points: int) -> bool:
	var enough = cur_time_points >= spend_points
	return enough


func spend_time_points(type_spend_action: TypeSpendAction, spend_points: int):
	_set_time_points(type_spend_action, cur_time_points - spend_points)


func restore_time_points():
	_set_time_points(TypeSpendAction.RESTORE_TURN, max_time_points)


func show_hint_spend_points(spend_points: int):
	GlobalBus.on_hint_time_points.emit(cur_time_points - spend_points, max_time_points)


func _set_time_points(type_spend_action: TypeSpendAction, value: int):
	cur_time_points = value
	GlobalBus.on_changed_time_points.emit(type_spend_action, cur_time_points, max_time_points)
	GlobalBus.on_hint_time_points.emit(cur_time_points, max_time_points)
