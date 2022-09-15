extends Node


@export var available_actions: Array

var best_action: Action = null
var is_finished_deciding := false


func decide_best_action_and_execute():
	decide_best_action(available_actions)
	best_action.execute()


func _process(delta: float) -> void:
	return
	
	if best_action == null:
		decide_best_action(available_actions)
	
	if is_finished_deciding:
		is_finished_deciding = false
		best_action.execute()


func decide_best_action(actions):
	var score: float = 0.0
	var next_best_action_idx = 0
	
	for i in actions.size():
		var cur_action = actions[i]
		if score_action(cur_action) > score:
			next_best_action_idx = i
			score = cur_action.score
	
	best_action = actions[next_best_action_idx]
	is_finished_deciding = true


func score_action(action: Action) -> float:
	var score: float = 1.0
	
	for consideration in action.considerations:
		var score_consideration: float = consideration.get_score()
		score *= score_consideration
		
		if score == 0:
			action.score = 0
			return action.score
	
	var original_score = score
	var mod_factor = 1 - (1 / action.considerations.size())
	var make_up_value = (1 - original_score) * mod_factor
	action.score = original_score + (make_up_value * original_score)
	
	return action.score
