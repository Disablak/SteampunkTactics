class_name ConsiderNotRotatedToAttention
extends Consideration


@export var attention_type: ConsiderAttentionDirExist.AttetntionType = ConsiderAttentionDirExist.AttetntionType.NONE


func calc_score() -> float:
	return 1.0 if is_not_rotated(attention_type) else 0.0


func is_not_rotated(type: ConsiderAttentionDirExist.AttetntionType) -> bool:
	var _cur_unit: Unit = GlobalUnits.get_cur_unit()

	match type:
		ConsiderAttentionDirExist.AttetntionType.DIR:
			return _cur_unit.unit_data.view_direction != _cur_unit.unit_data.attention_direction

		ConsiderAttentionDirExist.AttetntionType.POS:
			var first_enemy_grid_pos: Vector2i = _cur_unit.unit_data.visibility_data.enemies_saw.values().front()
			var angle: int = rad_to_deg(_cur_unit.unit_object.position.angle_to_point(Globals.convert_to_cell_pos(first_enemy_grid_pos)))
			return _cur_unit.unit_data.view_direction != angle

		_:
			printerr("not installed type")
			return false


func _to_string() -> String:
	return super._to_string() + "ConsiderNotRotatedToAttention"
