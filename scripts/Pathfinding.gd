class_name Pathfinding
extends Node2D


signal on_hovered_cell(cell_info: CellInfo)
signal on_clicked_cell(cell_info: CellInfo)

@onready var cell_hint := get_node("CellHovered") as Node2D

@export var walkable_hint_cell_scene: PackedScene
@export var node_with_walk_cells: Node2D
@export var node_with_walls: Node2D

const CELL_OFFSETS = [Vector2(-Globals.CELL_SIZE, 0), Vector2(Globals.CELL_SIZE, 0), Vector2(0, Globals.CELL_SIZE), Vector2(0, Globals.CELL_SIZE)]

var astar : AStar2D = AStar2D.new()

var dict_id_and_cell = {}
var spawned_walking_tiles = Array()
var obstacle_cells: Array[CellObject] = []
var cells_cover: Array[CellObject] = []

var prev_hovered_cell_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	GlobalBus.on_cell_broke.connect(_on_cell_broke)

	_connect_walkable_cells()
	_remove_wall_points()
	_covers()


func _connect_walkable_cells():
	for cell in node_with_walk_cells.get_children():
		var cell_pos: Vector2 = cell.position
		var id = astar.get_available_point_id()

		astar.add_point(id, cell_pos)
		dict_id_and_cell[id] = cell

	node_with_walk_cells.visible = false

	for cell in dict_id_and_cell.values():
		var cell_pos: Vector2 = cell.position
		var cell_id = astar.get_closest_point(cell_pos)

		for offset in CELL_OFFSETS:
			var potential_cell_pos : Vector2 = cell_pos + offset
			var potential_cell_id = astar.get_closest_point(potential_cell_pos)
			assert(potential_cell_id != -1, "cell id not found!" )
			var potential_cell = dict_id_and_cell.get(potential_cell_id)
			assert(potential_cell != null, "cell not found!" )

			if cell_id == potential_cell_id:
				continue

			if not astar.are_points_connected(cell_id, potential_cell_id):
				astar.connect_points(cell_id, potential_cell_id)
				#print("connected {0} and {1}".format([cell_id, potential_cell_id]))


func _remove_wall_points():
	for wall in node_with_walls.get_children():
		var wall_cell := wall as CellObject
		if wall_cell.cell_type != CellObject.CellType.WALL and wall_cell.cell_type != CellObject.CellType.OBSTACLE:
			continue

		obstacle_cells.push_back(wall_cell)
		var wall_pos: Vector2 = wall_cell.position
		var cell_id = astar.get_closest_point(wall_pos)
		astar.set_point_disabled(cell_id, true)


func _covers():
	for cell in node_with_walls.get_children():
		if cell.cell_type != CellObject.CellType.COVER:
			continue

		var conected_cell: CellObject = cell.connected_cells[0]

		cells_cover.append(cell)
		cells_cover.append(conected_cell)

		var first_cell_id := get_cell_id_by_pos(cell.position)
		var second_cell_id := get_cell_id_by_pos(cell.position + conected_cell.position)

		astar.disconnect_points(first_cell_id, second_cell_id)
		print("disconected {0}, {1}".format([first_cell_id, second_cell_id]))


func _on_cell_broke(cell: CellObject):
	if cell.cell_type == CellObject.CellType.COVER:
		_on_broke_cover(cell)
	if cell.cell_type == CellObject.CellType.OBSTACLE:
		_on_broke_obs(cell)


func _on_broke_cover(cell: CellObject):
	var conected_cell: CellObject = cell.connected_cells[0]

	cells_cover.erase(cell)
	cells_cover.erase(conected_cell)

	var first_cell_id := get_cell_id_by_pos(cell.position)
	var second_cell_id := get_cell_id_by_pos(cell.position + conected_cell.position)

	astar.connect_points(first_cell_id, second_cell_id)
	print("connected {0}, {1}".format([first_cell_id, second_cell_id]))

	cell.queue_free()


func _on_broke_obs(cell: CellObject):
	var cell_id = get_cell_id_by_pos(cell.position)
	astar.set_point_disabled(cell_id, false)

	obstacle_cells.erase(cell)

	cell.queue_free()


func get_path_to_point(from : Vector2i, to : Vector2i) -> PackedVector2Array:
	if not is_point_walkable(to):
		return PackedVector2Array()

	var from_id = astar.get_closest_point(from)
	var to_id = astar.get_closest_point(to)

	return astar.get_point_path(from_id, to_id)


func is_point_walkable(cell_pos : Vector2i) -> bool:
	var cell_obj: CellObject = get_cell_by_pos(cell_pos)
	return cell_obj != null and cell_obj.cell_type == CellObject.CellType.GROUND


func has_path(from: Vector2, to: Vector2) -> bool:
	var path: PackedVector2Array = get_path_to_point(from, to)
	return path.size() > 0 and path[path.size() - 1] == to


func get_unit_on_cell(cell_pos: Vector2) -> Unit:
	var all_units = GlobalUnits.units

	for unit in all_units.values():
		var unit_obj: UnitObject = unit.unit_object
		var unit_pos: Vector2 = unit_obj.position

		if cell_pos.distance_to(unit_pos) < Globals.CELL_SIZE:
			return unit

	return null


func get_walkable_cells(unit_pos: Vector2, max_distance: int) -> PackedVector2Array:
	if max_distance == 1:
		return PackedVector2Array()

	unit_pos = Globals.snap_to_cell_pos(unit_pos)

	var from_x : int = unit_pos.x - max_distance * Globals.CELL_SIZE
	var to_x : int   = unit_pos.x + max_distance * Globals.CELL_SIZE
	var from_y : int = unit_pos.y - max_distance * Globals.CELL_SIZE
	var to_y : int   = unit_pos.y + max_distance * Globals.CELL_SIZE

	var walkable_cells := PackedVector2Array()

	for x in range(from_x, to_x + Globals.CELL_SIZE, Globals.CELL_SIZE):
		for y in range(from_y, to_y + Globals.CELL_SIZE, Globals.CELL_SIZE):
			var cell_pos = Vector2(x, y)
			if cell_pos == unit_pos:
				continue

			if is_point_walkable(cell_pos):
				if has_path(unit_pos, cell_pos):
					if get_path_to_point(unit_pos, cell_pos).size() <= max_distance:
						walkable_cells.push_back(cell_pos)

	return walkable_cells


func draw_walking_cells(walking_cells: PackedVector2Array):
	clear_walking_cells()

	for cell_pos in walking_cells:
		var walkable: Node2D = walkable_hint_cell_scene.instantiate()
		add_child(walkable)
		spawned_walking_tiles.push_back(walkable)
		walkable.position = cell_pos


func clear_walking_cells():
	for tile in spawned_walking_tiles:
		tile.queue_free()

	spawned_walking_tiles.clear()


func is_unit_in_cover(unit_pos: Vector2, cell_cover: CellObject) -> bool:
	unit_pos = Globals.snap_to_cell_pos(unit_pos)

	if cell_cover.cell_type != CellObject.CellType.COVER:
		printerr("cell is not cover!")
		return false

	return unit_pos == cell_cover.position or unit_pos == cell_cover.connected_cells[0].position


func get_cell_id_by_pos(cell_pos: Vector2) -> int:
	cell_pos = Globals.snap_to_cell_pos(cell_pos)

	var cell_id := astar.get_closest_point(cell_pos, true)
	var cell_obj: CellObject = dict_id_and_cell[cell_id]

	var rect: Rect2 = Rect2(cell_pos - Globals.CELL_OFFSET, Vector2.ONE * Globals.CELL_SIZE)
	if rect.has_point(cell_obj.position):
		return cell_id

	return -1


func get_cell_by_pos(cell_pos: Vector2) -> CellObject:
	var cell_id = get_cell_id_by_pos(cell_pos)
	if cell_id != -1:
		return dict_id_and_cell[cell_id]

	var cell_wall := _get_closest_wall(cell_pos)
	if cell_pos.distance_to(cell_wall.position) < Globals.CELL_SIZE:
		return cell_wall

	return null


func get_cells_by_pattern(pos_center: Vector2, pattern_cells) -> Array[CellInfo]:
	pos_center = Globals.snap_to_cell_pos(pos_center)

	var result: Array[CellInfo]

	for cell_offset in pattern_cells:
		var cell_pos = pos_center + cell_offset * Globals.CELL_SIZE
		var cell_info = _get_cell_info(cell_pos)
		result.push_back(cell_info)

	return result


func _get_cell_info(cell_pos: Vector2) -> CellInfo:
	cell_pos = Globals.snap_to_cell_pos(cell_pos)

	var cell_obj := get_cell_by_pos(cell_pos)
	var unit_on_cell: Unit = get_unit_on_cell(cell_pos)
	var unit_id := unit_on_cell.id if unit_on_cell != null else -1

	return CellInfo.new(cell_pos, cell_obj, unit_id)


func _get_closest_wall(pos: Vector2) -> CellObject:
	var closest_wall: CellObject
	var closest_distance

	for wall in obstacle_cells:
		var distance = pos.distance_squared_to(wall.position)
		if closest_wall == null or distance < closest_distance:
			closest_wall = wall
			closest_distance = distance

	return closest_wall


func _on_input_system_on_mouse_hover(cell_info: CellInfo) -> void:
	var info = _get_cell_info(cell_info.cell_pos)

	if info.cell_obj != null and prev_hovered_cell_pos == info.cell_pos:
		return

	prev_hovered_cell_pos = info.cell_pos if info.cell_obj != null else Vector2.ZERO
	cell_hint.position = prev_hovered_cell_pos

	on_hovered_cell.emit(info)


func _on_input_system_on_mouse_click(cell_info: CellInfo) -> void:
	var info = _get_cell_info(cell_info.cell_pos)
	on_clicked_cell.emit(info)

	if info.cell_obj == null:
		print("clicked nowhere")
		return

	var clicked_tile_id := astar.get_closest_point(info.cell_pos)
	print("clicked on {0}".format([info.cell_obj.get_type_string()]))


