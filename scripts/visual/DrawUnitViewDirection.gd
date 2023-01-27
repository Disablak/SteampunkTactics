extends Node2D


var cur_unit: Unit


func _draw() -> void:
	if not cur_unit:
		return

	var center = cur_unit.unit_object.position
	var radius = cur_unit.unit_data.unit_settings.range_of_view * Globals.CELL_SIZE
	var view_dir =  cur_unit.unit_data.view_direction
	var angle_from = deg_to_rad(view_dir - FogOfWar.HALF_RADIUS)
	var angle_to = deg_to_rad(view_dir + FogOfWar.HALF_RADIUS)
	var color = Color.WHITE

	draw_arc(center, radius, angle_from, angle_to, 32, color)
	draw_line(center, center + Vector2(cos(angle_from), sin(angle_from)) * radius, color)
	draw_line(center, center + Vector2(cos(angle_to), sin(angle_to)) * radius, color)


func _on_pathfinding_on_hovered_cell(cell_info: CellInfo) -> void:
	if cell_info.unit_id == -1:
		cur_unit = null
		queue_redraw()
		return

	if not GlobalUnits.units[cell_info.unit_id].unit_data.is_enemy:
		cur_unit = null
		queue_redraw()
		return

	if cur_unit and cell_info.unit_id == cur_unit.id:
		cur_unit = null
		queue_redraw()
		return

	cur_unit = GlobalUnits.units[cell_info.unit_id]
	queue_redraw()
