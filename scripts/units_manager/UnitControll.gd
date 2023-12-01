class_name UnitControll
extends Node2D


@export var move_controll: MoveControll
@export var attack_controll: AttackControll
@export var object_selector: ObjectSelector

var cur_unit: Unit
var cur_action: UnitData.Abilities = UnitData.Abilities.WALK


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed)


func _on_unit_changed(id: int, instantly: bool):
	_enable_obstacle_for_prev_and_disable_for_new()


func _enable_obstacle_for_prev_and_disable_for_new():
	if cur_unit:
		cur_unit.unit_object.enable_obstacle()

	cur_unit = _get_cur_unit()
	if weakref(cur_unit).get_ref():
		cur_unit.unit_object.disable_obstacle()


func _get_cur_unit() -> Unit:
	return GlobalUnits.unit_list.get_cur_unit()


func _on_input_system_on_pressed_rmc(mouse_pos: Vector2) -> void:
	var cur_unit := _get_cur_unit();
	var is_any_hovered_obj := object_selector.is_any_hovered_obj()

	if is_any_hovered_obj:
		var enemy_object := object_selector.get_hovered_unit_object()
		var enemy: Unit = GlobalUnits.unit_list.get_unit(enemy_object.unit_id)
		if enemy_object:
			move_controll.deselect_move()
			attack_controll.try_to_attack(cur_unit, enemy)
	else:
		attack_controll.deselect_attack()
		move_controll.try_to_move(cur_unit.unit_object, mouse_pos)


