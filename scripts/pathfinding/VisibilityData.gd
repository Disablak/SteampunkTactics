class_name VisibilityData
extends RefCounted


var pos_last_check_visibility: Vector2i = Vector2.ZERO
var prev_view_direction: int = -1
var circle_points: Array[Vector2i]
var visible_points: Array[Vector2i]
var enemies_saw := {} # unit and last time saw pos
var enemy_attention_grid_pos: Vector2i


func unit_was_remembered(unit: Unit, last_time_saw_pos: Vector2i):
	enemies_saw[unit] = last_time_saw_pos
	print(enemies_saw)


func clear_enemies_saw():
	enemies_saw.clear()
