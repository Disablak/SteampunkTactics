class_name ShootToTargetAction
extends ActionLeaf


var _tween_timer: Tween
var _shoot_controll: ShootControll
var _is_finished: bool = false


func tick(actor: Node, blackboard: Blackboard) -> int:
	if _is_timer_not_over():
		return RUNNING

	if _is_finished:
		_is_finished = false
		return SUCCESS

	var unit: Unit = GlobalUnits.get_unit((actor as UnitObject).unit_id) as Unit
	var target_unit: Unit = blackboard.get_value(BehaviourAiConst.TARGET_ENEMY) as Unit
	_shoot_controll = GlobalUnits.unit_control.shoot_controll as ShootControll

	if not _shoot_controll.can_shoot(unit):
		return FAILURE

	_shoot_controll.enable_aim(unit)

	var dir: Vector2 = (target_unit.unit_object.aim_point - unit.origin_pos).normalized()
	_shoot_controll.set_aim_dir_and_disable_mouse(dir)

	_start_tween_delay_and_shoot()
	_is_finished = false

	return RUNNING


func _is_timer_not_over() -> bool:
	return _tween_timer and _tween_timer.is_valid() and _tween_timer.is_running()


func _start_tween_delay_and_shoot():
	_tween_timer = create_tween()
	_tween_timer.tween_interval(randf_range(0.5, 2))
	_tween_timer.tween_callback(_make_shoot)
	_tween_timer.play()


func _make_shoot():
	_shoot_controll.make_shoot()
	_shoot_controll.disable_aim()
	_is_finished = true
