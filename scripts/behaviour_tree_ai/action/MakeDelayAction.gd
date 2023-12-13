class_name MakeDelayAction
extends ActionLeaf


@export var delay_time: float = 1

var _tween_delay: Tween
var _is_finished: bool = false


func tick(actor: Node, blackboard: Blackboard) -> int:
	if _tween_delay and _tween_delay.is_running():
		return RUNNING

	if (_is_finished):
		return SUCCESS

	_is_finished = false
	_tween_delay = create_tween()
	_tween_delay.tween_interval(delay_time)
	_tween_delay.tween_callback(_set_is_finished_delay)
	_tween_delay.play()

	return RUNNING


func _set_is_finished_delay():
	_is_finished = true
