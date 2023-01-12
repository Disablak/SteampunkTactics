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


func _on_unit_moved(cell_pos: Vector2):
	var unit: Unit = GlobalUnits.get_cur_unit()

	if not unit.unit_data.unit_settings.is_enemy:
		update_unit_visibility_area(unit)


func spawn_fog(pos: Vector2, cell_visibility: CellVisibility):
	var spawned_fog: CellFog = cell_fog_scene.instantiate()
	spawned_fog.update_visibility(cell_visibility)
	add_child(spawned_fog)
	spawned_fog.position = pos

	dict_pos_and_cell[pos] = spawned_fog


func update_unit_visibility_area(unit: Unit):
	var unit_pos = Globals.snap_to_cell_pos(unit.unit_object.position)
	if unit_pos == visibility_data.pos_last_check_visibility:
		return

	visibility_data.pos_last_check_visibility = unit_pos
	visibility_data.circle_points = make_visible_spot(unit_pos, unit.unit_data.unit_settings.range_of_view)
#	visibility_data.visible_points.clear()
	var new_visible_points: Array[Vector2]

	for pos_on_circle in visibility_data.circle_points:
		var from: Vector2 = unit_pos / Globals.CELL_SIZE
		var to: Vector2 = pos_on_circle / Globals.CELL_SIZE

		var ray_positions = GlobalMap.raycaster.make_ray_and_get_positions(unit_pos, pos_on_circle, true)
		var formatted_end_pos = Globals.snap_to_cell_pos(ray_positions[1]) / Globals.CELL_SIZE
		var line_points = bresenham_line_thick(from.x, from.y, formatted_end_pos.x, formatted_end_pos.y)

		for point in line_points:
			if new_visible_points.has(point):
				continue

			new_visible_points.append(point)


	var new_not_visible_points: Array[Vector2]
	for point in new_visible_points:
		if visibility_data.visible_points.has(point):
			continue

		new_not_visible_points.append(point)

	var old_visible_points: Array[Vector2]
	for point in visibility_data.visible_points:
		if new_visible_points.has(point):
			continue

		old_visible_points.append(point)

	visibility_data.visible_points = new_visible_points

	update_visibility_on_cells(new_not_visible_points, 1, false)
	update_visibility_on_cells(old_visible_points, 2, false)


func make_visible_spot(pos_center: Vector2, radius: int) -> Array[Vector2]:
	pos_center = Globals.snap_to_cell_pos(pos_center)

	var x = radius
	var y = 0

	var all_points: Array[Vector2]

	all_points.append(Vector2(pos_center.x + (x * Globals.CELL_SIZE), pos_center.y))

	if radius > 0:
		all_points.append(Vector2(pos_center.x - (x * Globals.CELL_SIZE), pos_center.y))
		all_points.append(Vector2(pos_center.x, pos_center.y + (x * Globals.CELL_SIZE)))
		all_points.append(Vector2(pos_center.x, pos_center.y - (x * Globals.CELL_SIZE)))

	var p = 1 - radius

	while x > y:
		y += 1

		if p <= 0:
			p = p + 2 * y + 1
		else:
			x -= 1
			p = p + 2 * y - 2 * x + 1;

		if x < y:
			break

		var x_formatted = x * Globals.CELL_SIZE
		var y_formatted = y * Globals.CELL_SIZE

		all_points.append(Vector2(pos_center.x + x_formatted, pos_center.y + y_formatted))
		all_points.append(Vector2(pos_center.x - x_formatted, pos_center.y + y_formatted))
		all_points.append(Vector2(pos_center.x + x_formatted, pos_center.y - y_formatted))
		all_points.append(Vector2(pos_center.x - x_formatted, pos_center.y - y_formatted))

		if x == y:
			continue

		all_points.append(Vector2(pos_center.x + y_formatted, pos_center.y + x_formatted))
		all_points.append(Vector2(pos_center.x - y_formatted, pos_center.y + x_formatted))
		all_points.append(Vector2(pos_center.x + y_formatted, pos_center.y - x_formatted))
		all_points.append(Vector2(pos_center.x - y_formatted, pos_center.y - x_formatted))

	return all_points



func bresenham_line(from:Vector2, to: Vector2):
	var dx: int = abs(to.x - from.x)
	var sx: int = 1 if from.x < to.x else -1
	var dy: int = -abs(to.y - from.y)
	var sy: int = 1 if from.y < to.y else -1

	var error: int = dx + dy

	var points: Array[Vector2]

	while true:
		points.append(Vector2(from.x, from.y))

		if from.x == to.x && from.y == to.y:
			break

		var e2 = 2 * error
		if e2 >= dy:
			if from.x == to.x:
				break

			error += + dy
			from.x += + sx

		if e2 <= dx:
			if from.y == to.y:
				break

			error += dx
			from.y += sy

	return points


func bresenham_line_thick(ax, ay, bx, by):
	var points: Array[Vector2]

	var dx: int
	var dy: int
	var xinc: int
	var yinc: int
	var side: int
	var i: int
	var error: int

	points.append(Vector2(ax, ay))

	xinc = -1 if (bx < ax) else 1;
	yinc = -1 if (by < ay) else 1;
	dx   = xinc * (bx - ax);
	dy   = yinc * (by - ay);

	if dx == dy:
		while dx > 0:
			dx -= 1
			ax += xinc
			ay += yinc
			points.append(Vector2(ax, ay))

		return points

	side = -1 * ((yinc if dx == 0 else xinc) - 1);

	i     = dx + dy;
	error = dx - dy;

	dx *= 2;
	dy *= 2;

	while i > 0:
		i -= 1
		if error > 0 or error == side:
			ax    += xinc;
			error -= dy;
		else:
			ay    += yinc;
			error += dx;

		points.append(Vector2(ax, ay))

	return points


func update_visibility_on_cells(positions: Array[Vector2], visibility: CellVisibility, is_cell_pos: bool = true):
	for cell_pos in positions:
		update_visibility_on_cell(cell_pos, visibility, is_cell_pos)


func update_visibility_on_cell(cell_pos: Vector2, visibility: CellVisibility, is_cell_pos: bool = true):
	cell_pos = Globals.snap_to_cell_pos(cell_pos if is_cell_pos else cell_pos * Globals.CELL_SIZE)
	if dict_pos_and_cell.has(cell_pos):
		var cell_fog: CellFog = dict_pos_and_cell[cell_pos] as CellFog
		cell_fog.update_visibility(visibility)
