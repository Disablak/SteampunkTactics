extends Node2D


var cur_unit: Unit


func _ready() -> void:
	GlobalBus.on_hovered_cell.connect(_on_pathfinding_on_hovered_cell)


func _draw() -> void:
	if not cur_unit:
		return

	var center = cur_unit.unit_object.visual_pos
	var radius = cur_unit.unit_data.unit_settings.range_of_view * Globals.CELL_SIZE
	var color = Color.WHITE

	draw_arc(center, radius, 0, TAU, 32, color)


func _on_pathfinding_on_hovered_cell(cell_info: CellInfo) -> void:
	if cell_info.unit_id == -1:
		_clear()
		return

	var unit: Unit = GlobalUnits.units[cell_info.unit_id]

	if unit == null:
		_clear()
		return

	if not unit.unit_data.is_enemy:
		_clear()
		return

	if cur_unit and unit.id == cur_unit.id:
		return

	if not unit.unit_object.is_visible:
		_clear()
		return

	cur_unit = unit
	queue_redraw()


func _clear():
	cur_unit = null
	queue_redraw()
