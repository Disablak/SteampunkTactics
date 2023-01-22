extends Node


var CELL_AREA_3x3_WITHOUR_CENTER: Array[Vector2i] = [
	Vector2i.LEFT, Vector2i.RIGHT,
	Vector2i.UP, Vector2i.DOWN, Vector2i(1, 1),
	Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)]

var CELL_AREA_3x3: Array[Vector2i] = CELL_AREA_3x3_WITHOUR_CENTER + [Vector2i.ZERO]

var CELL_AREA_FOUR_DIR: Array[Vector2i] = [
	Vector2i.LEFT, Vector2i.RIGHT,Vector2i.UP, Vector2i.DOWN
]

var CELL_AREA_FOUR_DIR_DIAGONAL: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)
]

const GRID_STEP = 1.0
const CURVE_X_METERS = 3000
const CELL_SIZE := 32
const CELL_HALF_SIZE := CELL_SIZE / 2
const CELL_QUAD_SIZE := CELL_HALF_SIZE / 2
const CELL_OFFSET := Vector2(CELL_HALF_SIZE, CELL_HALF_SIZE)



static func get_total_distance(points) -> float:
	if points.size() <= 1:
		return 0.0

	var distance = 0.0
	var start: Vector2 = points[0]

	for i in range(1, points.size()):
		var end = points[i]
		distance += start.distance_to(end)
		start = points[i]

	return distance


static func format_hit_chance(hit_chance: float) -> String:
	return "%0.1f" % (hit_chance * 100) + "%"


static func snap_to_cell_pos(pos: Vector2) -> Vector2:
	return Vector2(snappedi(pos.x, CELL_SIZE), snappedi(pos.y, CELL_SIZE))


static func convert_to_grid_pos(pos: Vector2) -> Vector2i:
	return Vector2i(snap_to_cell_pos(pos)) / CELL_SIZE


static func convert_to_cell_pos(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos * CELL_SIZE)


static func convert_grid_poses_to_cell_poses(points: Array[Vector2i]) -> Array[Vector2]:
	var result = []
	for pos in points:
		result.append(convert_to_cell_pos(pos))

	return result


static func get_cells_of_type(cells: Array, cell_type: CellObject.CellType):
	var result = []
	for cell in cells:
		if cell is CellObject and cell.cell_type == cell_type and not cell.destroyed:
			result.append(cell)

	return result


func create_timer_and_get_signal(time: float) -> Signal:
	return get_tree().create_timer(time).timeout


func wait_while(condition: Callable) -> Signal:
	if condition.is_null():
		return get_tree().process_frame

	while condition.call() == true:
		await get_tree().process_frame

	return get_tree().process_frame


# Note: passing a value for the type parameter causes a crash
static func get_child_of_type(node: Node, child_type):
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		if child is child_type:
			return child


# Note: passing a value for the type parameter causes a crash
static func get_children_of_type(node: Node, child_type):
	var list = []
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		if child is child_type:
			list.append(child)
	return list


static func print_ai(str):
	print_rich("[color=purple][b]{0}[/b][/color]".format([str]))
