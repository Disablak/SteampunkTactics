class_name UnitControll
extends Node2D


@export var player: UnitObject
@export var move_controll: MoveControll

var cur_action: UnitData.Abilities = UnitData.Abilities.WALK


func _get_cur_unit() -> UnitObject:
	return player


func _on_input_system_on_pressed_rmc(mouse_pos: Vector2) -> void:
	var cur_unit = _get_cur_unit();
	move_controll.try_to_move(cur_unit, mouse_pos)

