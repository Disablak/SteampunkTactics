class_name FogOfWar
extends Node


enum CellVisibility {NONE, VISIBLE, HALF, NOTHING}

@export var cell_fog_scene: PackedScene

const AI_CONUS_RADIUS := 120
const HALF_RADIUS := AI_CONUS_RADIUS / 2
const RAY_ROOF_LENGTH := 3

var dict_pos_and_cell = {} # pos and cell fog
var dict_is_enemy_team_and_pos = {} # knew cells by team
var dict_is_enemy_and_visible_cells = {} # visible cells by team
var walls = {} # grid pos and cell object
var pathfinding: Pathfinding


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed_control)
	GlobalBus.on_unit_changed_view_direction.connect(_on_unit_changed_view_direction)
	GlobalBus.on_unit_moved_to_another_cell.connect(_on_unit_moved)


func _on_unit_changed_control(unit_id, _istantly):
	var unit: Unit = GlobalUnits.units[unit_id]
	update_fog(unit, true)


func _on_unit_moved(unit_id: int, cell_pos: Vector2):
	var unit: Unit = GlobalUnits.units[unit_id]
	update_fog(unit)


func _on_unit_changed_view_direction(unit_id, _angle, update_fog_of_war):
	if not update_fog_of_war:
		return

	var unit: Unit = GlobalUnits.units[unit_id]
	if not unit.unit_data.is_enemy:
		return

	update_fog(unit)


func init(pathfind):
	self.pathfinding = pathfind

	dict_is_enemy_and_visible_cells[false] = []
	dict_is_enemy_and_visible_cells[true] = []

	dict_is_enemy_team_and_pos[false] = []
	dict_is_enemy_team_and_pos[true] = []

	for cell_object in pathfinding.dict_pos_and_cell_wall.values():
		if cell_object.comp_wall.wall_type != CellCompWall.WallType.NONE:
			walls[cell_object.grid_pos] = cell_object

	for cell_object in pathfinding.dict_pos_and_cell_door.values():
		if cell_object.comp_wall.wall_type != CellCompWall.WallType.NONE:
			walls[cell_object.grid_pos] = cell_object

	for unit in GlobalUnits.units.values():
		_update_unit_visibility(unit)


func spawn_fog(grid_pos: Vector2i, cell_visibility: CellVisibility):
	var spawned_fog: CellFog = cell_fog_scene.instantiate()
	spawned_fog.update_visibility(cell_visibility)
	add_child(spawned_fog)
	spawned_fog.position = Globals.convert_to_cell_pos(grid_pos)

	dict_pos_and_cell[grid_pos] = spawned_fog


func update_fog(cur_unit: Unit, force_update: bool = false):
	if not cur_unit.unit_data.is_enemy:
		_make_all_map_in_fog()

	_update_visibility(cur_unit, force_update)
	_hide_units_in_fog(cur_unit)

	_enemies_trying_to_remember_unit(cur_unit)


func update_fog_for_all(force_update: bool = false):
	for unit in GlobalUnits.units.values():
		update_fog(unit, force_update)

	var cur_unit = GlobalUnits.get_cur_unit()
	if cur_unit:
		update_fog(cur_unit, force_update) # TODO optimization, not update for same unit


func is_unit_visible_to_enemy(unit: Unit):
	var unit_pos_grid := unit.unit_object.grid_pos
	return dict_is_enemy_and_visible_cells[not unit.unit_data.is_enemy].has(unit_pos_grid)


func _update_visibility(unit: Unit, force_update: bool = false):
	_update_team_visibility(unit.unit_data.is_enemy, force_update)
	var visible_cells: Array[Vector2i] = _get_team_visibility(unit.unit_data.is_enemy)
	dict_is_enemy_and_visible_cells[unit.unit_data.is_enemy] = visible_cells

	if unit.unit_data.is_enemy and not Globals.DEBUG_SHOW_ENEMY_ALWAYS:
		return

	_update_visibility_roof(unit.unit_data.visibility_data.roof_visible_points)
	_update_visibility_on_cells(visible_cells, CellVisibility.VISIBLE)


func update_and_get_cur_team_visibility() -> Array[Vector2i]:
	_update_team_visibility(GlobalUnits.get_cur_unit().unit_data.is_enemy)
	return _get_team_visibility(GlobalUnits.get_cur_unit().unit_data.is_enemy)


func _get_team_visibility(enemy_team: bool) -> Array[Vector2i]:
	var visible_cells: Array[Vector2i]
	for unit in GlobalUnits.get_units(enemy_team):
		visible_cells = MyMath.arr_add_no_copy(visible_cells, unit.unit_data.visibility_data.visible_points)

	return visible_cells


func _update_team_visibility(enemy_team: bool, force_update: bool = false):
	for unit in GlobalUnits.get_units(enemy_team):
		_update_unit_visibility(unit, force_update)


func _update_unit_visibility(unit: Unit, force_update: bool = false):
	var grid_unit_pos := unit.unit_object.grid_pos
	var unit_view_direction := unit.unit_data.view_direction
	var visibility_data = unit.unit_data.visibility_data

	if not force_update and grid_unit_pos == visibility_data.pos_last_check_visibility and unit_view_direction == visibility_data.prev_view_direction:
		return

	visibility_data.pos_last_check_visibility = grid_unit_pos
	visibility_data.prev_view_direction = unit_view_direction

	var all_circle_points := MyMath.get_circle_points(grid_unit_pos, unit.unit_data.unit_settings.range_of_view)
	var all_circle_points_roof := MyMath.get_circle_points(grid_unit_pos, RAY_ROOF_LENGTH)
	var sector_circle_points := MyMath.get_circle_sector_points(grid_unit_pos, all_circle_points, unit.unit_data.view_direction, HALF_RADIUS)

	const ALL_AROUND = 1000
	if not unit.unit_data.is_enemy or unit.unit_data.view_direction == ALL_AROUND:
		visibility_data.circle_points = all_circle_points
		if unit.unit_data.view_direction == ALL_AROUND:
			unit.unit_data.view_direction = -1
	else:
		visibility_data.circle_points = sector_circle_points

	GlobalMap.draw_debug.clear_draw_vision_lines()

	var new_visible_points: Array[Vector2i] = _get_filled_circle_points(grid_unit_pos, visibility_data.circle_points)
	var roof_visible_points: Array[Vector2i] = _get_filled_circle_points(grid_unit_pos, all_circle_points_roof, false)

	visibility_data.visible_points = new_visible_points
	visibility_data.roof_visible_points = roof_visible_points

	_know_new_cells(unit.unit_data.is_enemy, new_visible_points)


func _get_filled_circle_points(unit_pos: Vector2i, circle_points: Array[Vector2i], raycast: bool = true) -> Array[Vector2i]:
	var result: Array[Vector2i]
	for grid_pos_on_circle in circle_points:
		var line_points = _get_line_points(unit_pos, grid_pos_on_circle, raycast)
		result = MyMath.arr_add_no_copy(result, line_points)

	return result


func _get_line_points(grid_pos_from: Vector2i, grid_pos_to: Vector2i, raycast: bool = true) -> Array[Vector2i]:
	var from_pos := Globals.convert_to_cell_pos(grid_pos_from) + Globals.CELL_OFFSET
	var to_pos := Globals.convert_to_cell_pos(grid_pos_to) + Globals.CELL_OFFSET

	if not raycast:
		return MyMath.bresenham_line_thick(grid_pos_from, grid_pos_to)

	var ray_positions = GlobalMap.raycaster.make_ray_and_get_positions(from_pos, to_pos, true)
	var ray_dir = (ray_positions[1] - from_pos).normalized()
	var shorter_ray = ray_dir * (from_pos.distance_to(ray_positions[1]) - Globals.CELL_QUAD_SIZE) + from_pos
	var grid_end_pos = Globals.convert_to_grid_pos(shorter_ray)
	var line_points = MyMath.bresenham_line_thick(grid_pos_from, grid_end_pos)
	GlobalMap.draw_debug.draw_vision_lines([from_pos, shorter_ray])

	return line_points


func _update_visibility_on_cells(grid_poses: Array[Vector2i], visibility: CellVisibility):
	for grid_pos in grid_poses:
		_update_visibility_on_cell(grid_pos, visibility)

	_update_walls()


func _update_visibility_roof(grid_poses: Array[Vector2i]):
	var visible_roofs = grid_poses.filter(func(grid_pos): return pathfinding.level.is_roof_exist_and_visible(grid_pos))
	for grid_pos in visible_roofs:
		_update_visibility_on_cell(grid_pos, CellVisibility.VISIBLE)

	_know_new_cells(GlobalUnits.cur_unit_is_enemy, visible_roofs)


func _update_walls():
	for cell_object in walls.values():
		if cell_object.comp_wall.wall_type == CellCompWall.WallType.BOT or cell_object.comp_wall.wall_type == CellCompWall.WallType.TOP:
			_update_top_down_wall(cell_object)


func _update_top_down_wall(wall: CellObject):
	if not dict_pos_and_cell.has(wall.grid_pos):
		return

	var cell_fog_front = dict_pos_and_cell[wall.grid_pos]
	if cell_fog_front.visibility == CellVisibility.VISIBLE or cell_fog_front.visibility == CellVisibility.HALF:
		dict_pos_and_cell[wall.grid_pos + Vector2i(0, -1)].update_visibility(cell_fog_front.visibility)
		_know_new_cells(GlobalUnits.get_cur_unit().unit_data.is_enemy, [wall.grid_pos])


func _update_visibility_on_cell(grid_pos: Vector2i, visibility: CellVisibility):
	if dict_pos_and_cell.has(grid_pos):
		var cell_fog: CellFog = dict_pos_and_cell[grid_pos] as CellFog
		cell_fog.update_visibility(visibility)


func _hide_units_in_fog(unit: Unit):
	var my_team = GlobalUnits.get_units(unit.unit_data.is_enemy)
	for cur_unit in my_team:
		cur_unit.unit_object.set_visibility(true)

	var enemies = GlobalUnits.get_units(not unit.unit_data.is_enemy)

	for enemy in enemies:
		var grid_pos := Globals.convert_to_grid_pos(enemy.unit_object.position)
		var fog_on_this_pos: CellFog = dict_pos_and_cell[grid_pos]

		var is_visible = fog_on_this_pos.visibility == CellVisibility.VISIBLE or Globals.DEBUG_SHOW_ENEMY_ALWAYS
		enemy.unit_object.set_visibility(is_visible)


func _make_all_map_in_fog():
	var is_enemy = GlobalUnits.get_cur_unit().unit_data.is_enemy
	var knew_cells = dict_is_enemy_team_and_pos[is_enemy]
	var can_show_visibility = GlobalMap.can_show_cur_unit()

	for fog in dict_pos_and_cell.values():
		var grid_pos = Globals.convert_to_grid_pos(fog.position)
		if Globals.DEBUG_HIDE_FOG and can_show_visibility and knew_cells.has(grid_pos):
			fog.update_visibility(CellVisibility.HALF)
		else:
			fog.update_visibility(CellVisibility.NOTHING)


func _enemies_trying_to_remember_unit(unit: Unit):
	var enemies := GlobalUnits.get_units(not unit.unit_data.is_enemy)
	for enemy in enemies:
		var enemy_visibility_data := enemy.unit_data.visibility_data
		if enemy_visibility_data.visible_points.has(unit.unit_object.grid_pos):
			print("unit{0} saw unit{1}".format([enemy.id, unit.id]))
			enemy_visibility_data.unit_was_remembered(unit, unit.unit_object.grid_pos)
			enemy.unit_object.show_noticed_icon(true)


func _know_new_cells(is_enemy, visible_points: Array[Vector2i]):
	var prev_visible_points = dict_is_enemy_team_and_pos[is_enemy]
	prev_visible_points = MyMath.arr_add_no_copy(prev_visible_points, visible_points)

	dict_is_enemy_team_and_pos[is_enemy] = prev_visible_points

