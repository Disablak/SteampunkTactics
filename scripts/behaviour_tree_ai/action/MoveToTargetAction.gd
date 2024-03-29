class_name MoveToTargetAction
extends ActionLeaf


var _cur_unit: Unit
var _move_controll: MoveControll


func before_run(actor: Node, blackboard: Blackboard):
	var unit_object := actor as UnitObject
	_cur_unit = GlobalUnits.unit_list.get_unit(unit_object.unit_id)
	_move_controll = GlobalUnits.unit_control.move_controll


func tick(actor: Node, blackboard: Blackboard):
	var target_pos: Vector2 = blackboard.get_value("move_pos")
	var is_unit_moving := _move_controll.object_mover.is_object_moving()
	var is_too_far: bool = _cur_unit.origin_pos.distance_to(target_pos) > 1

	if is_unit_moving and is_too_far:
		return RUNNING

	if not is_too_far:
		_move_controll.deselect_move()
		return SUCCESS

	_move_controll.try_show_hint(_cur_unit, target_pos)
	_move_controll.try_to_move(_cur_unit, target_pos)

	PrintDebug.print_ai("moving to {0}".format([target_pos]))
	return RUNNING
