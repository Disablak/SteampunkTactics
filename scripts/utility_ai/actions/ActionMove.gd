class_name ActionMove
extends Action


enum MoveTo {NONE, RANDOM_CELL, PATRUL_ZONE, ENEMY, COVER, ATTENTION}
@export var move_to: MoveTo = MoveTo.NONE


func execute_action():
	match move_to:
		MoveTo.RANDOM_CELL:
			ai_world.walk_to_rand_cell()

		MoveTo.PATRUL_ZONE:
			ai_world.walk_to_patrul_zone()

		MoveTo.ENEMY:
			ai_world.walk_to_near_enemy()

		MoveTo.COVER:
			ai_world.walk_to_cover()

		MoveTo.ATTENTION:
			ai_world.walk_to_attention_pos()


func _to_string() -> String:
	return "ActionMove to {0}".format([MoveTo.keys()[move_to]])
