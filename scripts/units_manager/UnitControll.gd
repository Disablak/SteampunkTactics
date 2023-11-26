class_name UnitControll
extends Node2D


@export var player: UnitObject
@export var move_controll: MoveControll
@export var attack_controll: AttackControll
@export var object_selector: ObjectSelector

var cur_action: UnitData.Abilities = UnitData.Abilities.WALK


func _get_cur_unit() -> UnitObject:
	return player


func _on_input_system_on_pressed_rmc(mouse_pos: Vector2) -> void:
	var cur_unit := _get_cur_unit();
	var is_any_hovered_obj := object_selector.is_any_hovered_obj()

	if is_any_hovered_obj:
		var enemy_object := object_selector.get_hovered_unit_object()
		if enemy_object:
			move_controll.deselect_move()
			attack_controll.try_to_attack(cur_unit, enemy_object)
	else:
		attack_controll.deselect_attack()
		move_controll.try_to_move(cur_unit, mouse_pos)


