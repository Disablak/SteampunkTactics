class_name FogOfWar
extends Node


enum CellVisibility {NONE, VISIBLE, HALF, NOTHING}

@export var cell_fog_scene: PackedScene

var dict_pos_and_cell = {}


func spawn_fog(pos: Vector2, cell_visibility: CellVisibility):
	var spawned_fog: CellFog = cell_fog_scene.instantiate()
	spawned_fog.update_visibility(cell_visibility)
	add_child(spawned_fog)
	spawned_fog.position = pos

	dict_pos_and_cell[pos] = spawned_fog


func make_visible_spot(pos_center: Vector2, radius: int):
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


	for cell_pos in all_points:
		cell_pos = Globals.snap_to_cell_pos(cell_pos)
		print(cell_pos)
		if dict_pos_and_cell.has(cell_pos):
			var cell_fog: CellFog = dict_pos_and_cell[cell_pos] as CellFog
			cell_fog.update_visibility(1)
