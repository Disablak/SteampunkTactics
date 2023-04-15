class_name BrainAI
extends Node2D


@export var default_actions: Array[Action]
@export var next_turn_action: Action

var available_actions: Array[Action]
var is_game_over: bool = false


func init():
	GlobalBus.on_unit_moved_to_another_cell.connect(_on_unit_moved)
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed_control)


func start_ai(unit: Unit):
	_set_actions(unit.unit_data.ai_actions)
	decide_best_action_and_execute()


func _on_unit_moved(unit_id: int, cell_pos: Vector2):
	var unit: Unit = GlobalUnits.units[unit_id]
	if unit.unit_data.is_enemy:
		return

	for enemy in GlobalUnits.get_enemies_in_range(unit):
		enemy.unit_data.ai_settings.change_state_to_active()


func _on_unit_changed_control(unit_id: int, instantly: bool):
	_on_unit_moved(unit_id, Vector2.ZERO)


func _set_actions(actions: Array[Action]):
	available_actions.clear()
	available_actions.append_array(default_actions)
	available_actions.append_array(actions)
	Globals.print_ai("Inited {0} actions!".format([available_actions.size()]))


func decide_best_action_and_execute():
	if is_game_over:
		return

	var best_action : Action = _decide_best_action(available_actions)

	if best_action != null:
		best_action.execute_action()
		Globals.print_ai("Execute {0}".format([best_action.to_string()]), true, "red")
	else:
		next_turn_action.execute_action()
		Globals.print_ai("No actions available, next turn!", true, "red")


func _decide_best_action(actions) -> Action:
	var score: float = 0.0
	var cur_best_action: Action = null

	for cur_action in actions:
		if _score_action(cur_action) > score:
			cur_best_action = cur_action
			score = cur_action.score

	return cur_best_action


func _score_action(action: Action) -> float:
	var score: float = 1.0

	for consideration in action.considerations:
		var score_consideration: float = consideration.get_score()
		score *= score_consideration

		if score == 0:
			action.score = 0
			action.print_debug()
			return action.score

	var original_score = score
	var mod_factor = 1 - (1 / action.considerations.size())
	var make_up_value = (1 - original_score) * mod_factor
	action.score = original_score + (make_up_value * original_score)
	action.print_debug()

	return action.score
