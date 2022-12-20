extends Node2D


@export var focus_time = 0.2

var tween_move: Tween


func focus_camera(target: Node2D, instantly: bool = false):
	var target_pos: Vector2 = target.position

	if instantly:
		position = target_pos
		return

	tween_move = create_tween()
	tween_move.set_trans(Tween.TRANS_SINE)
	tween_move.tween_property(
		self,
		"position",
		target_pos,
		focus_time
	)
