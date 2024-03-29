extends Node


var CELL_AREA_3x3_WITHOUR_CENTER: Array[Vector2i] = [
	Vector2i.LEFT, Vector2i.RIGHT,
	Vector2i.UP, Vector2i.DOWN, Vector2i(1, 1),
	Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)]

var CELL_AREA_3x3: Array[Vector2i] = [
	Vector2i.LEFT, Vector2i.RIGHT,
	Vector2i.UP, Vector2i.DOWN, Vector2i(1, 1),
	Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i.ZERO]

var CELL_AREA_FOUR_DIR: Array[Vector2i] = [
	Vector2i.LEFT, Vector2i.RIGHT,Vector2i.UP, Vector2i.DOWN
]

var CELL_AREA_FOUR_DIR_DIAGONAL: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)
]

const GRID_STEP = 1.0
const CURVE_X_METERS = 10
const CELL_SIZE := 16
const CELL_HALF_SIZE := CELL_SIZE / 2
const CELL_QUAD_SIZE := CELL_HALF_SIZE / 2
const CELL_OFFSET := Vector2(CELL_HALF_SIZE, CELL_HALF_SIZE)
const TP_TO_OPEN_DOOR := 10

# colors
const COLOR_0 = Color("#0e0e12")
const COLOR_1 = Color("#1a1a24")
const COLOR_2 = Color("#333346")
const COLOR_3 = Color("#535373")
const COLOR_4 = Color("#8080a4")
const COLOR_5 = Color("#a6a6bf")
const COLOR_6 = Color("#c1c1d2")
const COLOR_7 = Color("#e6e6ec")

# debug
const DEBUG_AI = true
var DEBUG_HIDE_FOG := false
var DEBUG_SHOW_ENEMY_ALWAYS := false
var DEBUG_FOW_RAYCASTS := false
var DEBUG_OBJECTS_ORDERING := false
var DEBUG_MALEE_ATACK_RAYS := false
var DEBUG_GRID_POS := false

var main_atlas_image: Image


func _ready() -> void:
	main_atlas_image = Image.load_from_file("res://content/sprites/gothic/gothic_sheet_0.png")


func get_height_of_obj(region: Rect2) -> int:
	for y in range(region.end.y, region.position.y, -1):
		for x in range(region.position.x, region.end.x):
			var pixel = main_atlas_image.get_pixel(x, y - 1)
			if pixel.a != 0:
				return y - region.position.y

	printerr("sprite is empty")
	return -1





static func format_hit_chance(hit_chance: float) -> String:
	return "%0.1f" % (hit_chance * 100) + "%"


static func snap_to_cell_pos(pos: Vector2) -> Vector2:
	return Vector2(snappedi(pos.x, CELL_SIZE), snappedi(pos.y, CELL_SIZE))


static func convert_to_grid_pos(pos: Vector2) -> Vector2i:
	return floor(pos / CELL_SIZE)


static func convert_to_cell_pos(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos * CELL_SIZE)


static func convert_to_visual_pos(grid_pos: Vector2i) -> Vector2:
	return convert_to_cell_pos(grid_pos) + CELL_OFFSET


static func convert_grid_poses_to_cell_poses(points: Array[Vector2i]) -> Array[Vector2]:
	var result: Array[Vector2]
	for pos in points:
		result.append(convert_to_cell_pos(pos))

	return result


static func get_cells_of_type(cells: Array, cell_type: CellObject.CellType) -> Array[CellObject]:
	var result: Array[CellObject]
	for cell in cells:
		if cell is CellObject and cell.cell_type == cell_type:
			result.append(cell)

	return result




static func get_cells_by_node2d(node: Node2D) -> Array[Vector2i]:
	var zone_rect = Rect2i(Globals.convert_to_grid_pos(node.position), node.scale)
	var result: Array[Vector2i]
	for x in zone_rect.size.x:
			for y in zone_rect.size.y:
				result.append(zone_rect.position + Vector2i(x, y))

	return result



func create_timer_and_get_signal(time: float) -> Signal:
	return get_tree().create_timer(time).timeout


func wait_while(condition: Callable) -> Signal:
	if condition.is_null():
		return get_tree().process_frame

	while condition.call() == true:
		await get_tree().process_frame

	return get_tree().process_frame


static func print_ai(str, bold: bool = false, color = "white"):
	if not DEBUG_AI:
		return

	if bold:
		print_rich("[color={0}][b]{1}[/b][/color]".format([color, str]))
	else:
		print_rich("[color={0}]{1}[/color]".format([color, str]))
