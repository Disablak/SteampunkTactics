class_name VisibilityData
extends RefCounted


var pos_last_check_visibility: Vector2i = Vector2.ZERO
var prev_view_direction: int = -1
var circle_points: Array[Vector2i]
var visible_points: Array[Vector2i]
var roof_visible_points: Array[Vector2i]

var enemies_saw := {} # unit and last time saw pos
var enemy_attention_grid_pos: Vector2i


func unit_was_remembered(unit: Unit, last_time_saw_pos: Vector2i):
	enemies_saw[unit] = last_time_saw_pos
	print(enemies_saw)


func clear_enemies_saw():
	enemies_saw.clear()


func is_enemy_was_noticed(unit: Unit):
	for enemy in enemies_saw:
		if enemy.id == unit.id:
			return true


func is_see_enemy() -> bool:
	for pos in visible_points:
		for unit in GlobalUnits.get_units(not GlobalUnits.get_cur_unit().unit_data.is_enemy):
			if pos == unit.unit_object.grid_pos:
				return true

	return false
