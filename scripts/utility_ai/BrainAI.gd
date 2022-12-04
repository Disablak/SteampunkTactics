class_name BrainAI
extends Node2D


@export var available_actions: Array


func decide_best_action_and_execute():
	var best_action : Action = decide_best_action(available_actions)

	if best_action != null and best_action.is_enough_time_points_to_execute():
		best_action.execute_action()
	else:
		print("no actions available!")


func decide_best_action(actions) -> Action:
	var score: float = 0.0
	var cur_best_action : Action = null

	for cur_action in actions:
		cur_action.pre_action()

		if score_action(cur_action) > score:
			cur_best_action = cur_action
			score = cur_action.score

	return cur_best_action


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
