class_name BattleStates
extends Node2D


enum BattleState{
	NONE,
	MY_TURN,
	ENEMY_TURN,
	MY_WIN,
	ENEMY_WIN
	}

signal on_changed_battle_state(battle_states: BattleStates)

@export var unit_list: UnitList

var _cur_state: BattleState = BattleState.NONE

var cur_state: BattleState:
	get: return _cur_state

var is_game_over: bool:
	get: return _cur_state == BattleState.MY_WIN or _cur_state == BattleState.ENEMY_WIN


func _enter_tree() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed_control)
	GlobalBus.on_unit_died.connect(_on_unit_died)


func _on_unit_changed_control(id, instantly):
	_change_unit_state_turn(id)


func _on_unit_died(id, id_killer):
	_check_win_and_change_state()


func _change_unit_state_turn(id):
	var unit: Unit = GlobalUnits.get_unit(id) as Unit

	if unit.unit_data.is_enemy:
		_change_state(BattleState.ENEMY_TURN)
	else:
		_change_state(BattleState.MY_TURN)


func _check_win_and_change_state():
	var all_player_units := unit_list.get_team_units(false)
	var all_enemy_units := unit_list.get_team_units(true)

	if all_player_units.size() == 0:
		_change_state(BattleState.ENEMY_WIN)
	elif all_enemy_units.size() == 0:
		_change_state(BattleState.MY_WIN)


func _change_state(state: BattleState):
	if state == _cur_state:
		return

	_cur_state = state
	on_changed_battle_state.emit(self)
