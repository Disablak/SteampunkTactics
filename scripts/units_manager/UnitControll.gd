class_name UnitControll
extends Node2D


@export var object_selector: ObjectSelector
@export var move_controll: MoveControll
@export var shoot_controll: ShootControll
@export var reload_controll: ReloadControll
@export var melle_attack_controll: MelleeAttackControll

var cur_unit: Unit
var cur_action: UnitData.UnitAction = UnitData.UnitAction.WALK


func deinit():
	cur_unit = null
	cur_action = UnitData.UnitAction.WALK


func _enter_tree() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed)
	GlobalBus.on_unit_changed_action.connect(_on_unit_changed_action)


func _on_unit_changed(id: int, instantly: bool):
	_finish_for_prev_start_for_new()
	cur_unit.unit_data.change_action(UnitData.UnitAction.NONE)


func _on_unit_changed_action(id: int, action: UnitData.UnitAction):
	move_controll.deselect_move()
	shoot_controll.disable_aim()

	match action:
		UnitData.UnitAction.RELOAD:
			reload_controll.try_to_reload(cur_unit)

		UnitData.UnitAction.SHOOT:
			if shoot_controll.can_shoot(cur_unit):
				shoot_controll.enable_aim(cur_unit)


func _finish_for_prev_start_for_new():
	_finish_turn_unit()
	cur_unit = GlobalUnits.unit_list.get_cur_unit()
	_start_turn_unit()


func _finish_turn_unit():
	if weakref(cur_unit).get_ref():
		cur_unit.unit_object.enable_obstacle()
		cur_unit.unit_object.try_to_finish_ai()


func _start_turn_unit():
	if weakref(cur_unit).get_ref():
		cur_unit.unit_object.disable_obstacle()
		cur_unit.unit_object.try_to_start_ai()


func _on_right_click_mouse(mouse_pos: Vector2):
	var is_hovered_on_obj := object_selector.is_any_hovered_obj()
	try_move(mouse_pos, is_hovered_on_obj)

	#return
#
	#match cur_unit.unit_data.cur_action:
		#UnitData.UnitAction.NONE:
			#return
#
		#UnitData.UnitAction.WALK:
			#try_move(mouse_pos, is_hovered_on_obj)
#
		#UnitData.UnitAction.SHOOT:
			#_try_shoot(is_hovered_on_obj)
#
		#UnitData.UnitAction.MALEE_ATACK:
			#_try_melee_attack()


func try_move(mouse_pos: Vector2, is_hovered_on_obj: bool):
	if is_hovered_on_obj or shoot_controll.aim_enabled:
		return

	var world_pos: Vector2 = GlobalUtils.screen_pos_to_world_pos(mouse_pos)
	move_controll.try_to_move_or_show_hint(cur_unit, world_pos)


func _try_shoot(is_hovered_on_obj: bool):
	if not is_hovered_on_obj:
		return

	shoot_controll.enable_aim(cur_unit)


func _try_melee_attack():
	var enemy: Unit = object_selector.get_hovered_unit()
	melle_attack_controll.try_attack_mini_game(cur_unit, enemy)


func _reset_unit_action():
	cur_unit.unit_data.change_action(UnitData.UnitAction.NONE)


func _on_input_system_on_pressed_rmc(mouse_pos: Vector2) -> void:
	_on_right_click_mouse(mouse_pos);


func _on_input_system_on_pressed_esc() -> void:
	_reset_unit_action()


func _on_battle_states_on_changed_battle_state(battle_states: BattleStates) -> void:
	if battle_states.is_game_over:
		cur_unit.unit_object.try_to_finish_ai()
		print("game over")


func _on_input_system_on_aim_enabled() -> void:
	_reset_unit_action()
	shoot_controll.enable_aim(cur_unit)


func _on_input_system_on_aim_disabled() -> void:
	shoot_controll.disable_aim()
