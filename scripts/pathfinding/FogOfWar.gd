class_name FogOfWar
extends Node


enum CellVisibility {NONE, VISIBLE, HALF, NOTHING}

@export var cell_fog_scene: PackedScene

var visibility_data: VisibilityData = VisibilityData.new()
var dict_pos_and_cell = {}


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed_control)

	await get_tree().process_frame
	GlobalUnits.units_manager.walking.on_moved_to_another_cell.connect(_on_unit_moved)


func _on_unit_changed_control(unit_id, _istantly):
	var unit: Unit = GlobalUnits.units[unit_id]

	if not unit.unit_data.unit_settings.is_enemy:
		update_unit_visibility_area(unit)

	_check_is_enemy_visible(unit)


func _on_unit_moved(cell_pos: Vector2):
	var unit: Unit = GlobalUnits.get_cur_unit()

	if not unit.unit_data.unit_settings.is_enemy:
		update_unit_visibility_area(unit)

	_check_is_enemy_visible(unit)


func spawn_fog(pos: Vector2, cell_visibility: CellVisibility):
	var spawned_fog: CellFog = cell_fog_scene.instantiate()
	spawned_fog.update_visibility(cell_visibility)
	add_child(spawned_fog)
	spawned_fog.position = pos

	dict_pos_and_cell[pos] = spawned_fog


func update_unit_visibility_area(unit: Unit):
	var unit_pos = Globals.snap_to_cell_pos(unit.unit_object.position)
	var grid_unit_pos: Vector2 = unit_pos / Globals.CELL_SIZE
	if grid_unit_pos == visibility_data.pos_last_check_visibility:
		return

	visibility_data.pos_last_check_visibility = grid_unit_pos
	visibility_data.circle_points = MyMath.get_circle_points(grid_unit_pos, unit.unit_data.unit_settings.range_of_view)
#
	var new_visible_points: Array[Vector2]
	for grid_pos_on_circle in visibility_data.circle_points:
		var line_points = _get_line_points(grid_unit_pos, grid_pos_on_circle)
		new_visible_points = MyMath.arr_add_no_copy(new_visible_points, line_points)

	var new_points: Array[Vector2] = MyMath.arr_except(new_visible_points, visibility_data.visible_points)
	var old_points: Array[Vector2] = MyMath.arr_except(visibility_data.visible_points, new_visible_points)

	update_visibility_on_cells(new_points, CellVisibility.VISIBLE, false)
	update_visibility_on_cells(old_points, CellVisibility.HALF, false)

	visibility_data.visible_points = new_visible_points


func _get_line_points(grid_pos_from: Vector2, grid_pos_to: Vector2) -> Array[Vector2]:
	var from_pos: Vector2 = grid_pos_from * Globals.CELL_SIZE
	var to_pos: Vector2 = grid_pos_to * Globals.CELL_SIZE

	var ray_positions = GlobalMap.raycaster.make_ray_and_get_positions(from_pos, to_pos, true)
	var ray_dir = (ray_positions[1] - from_pos).normalized()
	var shorter_ray = ray_dir * (from_pos.distance_to(ray_positions[1]) - Globals.CELL_QUAD_SIZE) + from_pos
	var grid_end_pos = Globals.snap_to_cell_pos(shorter_ray) / Globals.CELL_SIZE
	var line_points = MyMath.bresenham_line_thick(grid_pos_from, grid_end_pos)

	return line_points


func update_visibility_on_cells(positions: Array[Vector2], visibility: CellVisibility, is_cell_pos: bool = true):
	for cell_pos in positions:
		update_visibility_on_cell(cell_pos, visibility, is_cell_pos)


func update_visibility_on_cell(cell_pos: Vector2, visibility: CellVisibility, is_cell_pos: bool = true):
	cell_pos = Globals.snap_to_cell_pos(cell_pos if is_cell_pos else cell_pos * Globals.CELL_SIZE)
	if dict_pos_and_cell.has(cell_pos):
		var cell_fog: CellFog = dict_pos_and_cell[cell_pos] as CellFog
		cell_fog.update_visibility(visibility)


func _check_is_enemy_visible(unit: Unit):
	if unit.unit_data.unit_settings.is_enemy:
		return

	var my_team = GlobalUnits.get_units(unit.unit_data.unit_settings.is_enemy)
	for cur_unit in my_team:
		cur_unit.unit_object.set_visibility(true)

	var enemies = GlobalUnits.get_units(not unit.unit_data.unit_settings.is_enemy)

	for enemy in enemies:
		var pos = enemy.unit_object.position
		var fog_on_this_pos: CellFog = dict_pos_and_cell[pos]

		var is_visible = fog_on_this_pos.visibility == CellVisibility.VISIBLE
		enemy.unit_object.set_visibility(is_visible)
