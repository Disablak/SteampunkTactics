@tool
class_name Pathfinding
extends Node2D


@onready var fog_of_war := get_node("FogOfWar") as FogOfWar
@onready var cell_hint := get_node("CellHovered") as Node2D

@export var is_debug := true
@export var walkable_hint_cell_scene: PackedScene
@export var cell_damage_hint_scene: PackedScene

@export_group("Walking cells setting")
@export var scene_walk_cell: PackedScene
@export var offset_spawn_cells: Vector2i
@export var walk_field_size: Vector2i
@export var spawn: bool: set = _tool_spawn_walk_cells

var level: Level
var root_walk_hint: Node2D
var root_obs_cells: Node2D


const CELL_OFFSETS = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, 1)]

var astar : AStar2D = AStar2D.new()

var walk_grid_poses: Array[Vector2i]
var dict_id_and_walk_pos = {}
var dict_pos_and_cell_wall = {}
var dict_pos_and_cell_obstacle = {}
var dict_pos_and_cell_cover = {}
var dict_pos_and_cell_door = {}

var spawned_walk_hints = Array()
var spawned_damage_hints := []

var prev_hovered_cell_pos: Vector2i = Vector2i.ZERO
var hovered_obj: CellObject

var debug_lines = []


func _draw_debug() -> void:
	if not is_debug:
		return

	for deb in debug_lines:
		deb.queue_free()

	for cell_id in dict_id_and_walk_pos:
		var cell_walk = dict_id_and_walk_pos[cell_id]

		if astar.is_point_disabled(cell_id):
			continue

		var connected_points = astar.get_point_connections(cell_id)
		for conn_id in connected_points:
			if astar.is_point_disabled(conn_id):
				continue

			var conn_cell = dict_id_and_walk_pos[conn_id]
			var line = DrawDebug.line2d(cell_walk.position, conn_cell.position)
			debug_lines.append(line)


func _tool_spawn_walk_cells(tmp):
	if not Engine.is_editor_hint() or get_child_count() <= 2:
		return

	var root: Node2D = get_child(0).get_node_or_null("RootWalkCells")
	if root == null:
		return

	for child in root.get_children():
		child.queue_free()

	for x in range(0, walk_field_size.x):
		for y in range(0, walk_field_size.y):
			var spawned: Node2D = scene_walk_cell.instantiate()
			root.add_child(spawned)
			spawned.set_owner(get_tree().edited_scene_root)

			spawned.position = offset_spawn_cells + Vector2i(x, y) * Globals.CELL_SIZE


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	GlobalBus.on_cell_broke.connect(_on_cell_broke)


func init() -> void:
	level = get_child(0)
	root_walk_hint = level.get_node("RootWalkHint")
	root_obs_cells = level.get_node("RootObsCells")

	_connect_walkable_cells()
	_add_obstacles()

	fog_of_war.init(self)

	_draw_debug()


func _connect_walkable_cells():
	for x in level.map_size.x:
		for y in level.map_size.y:
			var id = astar.get_available_point_id()
			var grid_pos = Vector2i(x, y)

			astar.add_point(id, grid_pos)
			dict_id_and_walk_pos[id] = grid_pos
			walk_grid_poses.append(grid_pos)

			fog_of_war.spawn_fog(grid_pos, 2)


	for walk_pos in dict_id_and_walk_pos.values():
		var cell_id = astar.get_closest_point(walk_pos)

		for offset in CELL_OFFSETS:
			var potential_grid_pos : Vector2i = walk_pos + offset
			var potential_cell_id = astar.get_closest_point(potential_grid_pos)
			var potential_cell = dict_id_and_walk_pos.get(potential_cell_id)

			if cell_id == potential_cell_id:
				continue

			if not astar.are_points_connected(cell_id, potential_cell_id):
				astar.connect_points(cell_id, potential_cell_id)


func _add_obstacles():
	for cell in root_obs_cells.get_children():
		var cell_obj := cell as CellObject

		if cell_obj.cell_type == CellObject.CellType.WALL:
			dict_pos_and_cell_wall[cell_obj.grid_pos] = cell_obj
			_enable_connection(cell_obj, false)

		if cell_obj.cell_type == CellObject.CellType.OBSTACLE:
			dict_pos_and_cell_obstacle[cell_obj.grid_pos] = cell_obj
			_enable_point_by_pos(cell_obj.grid_pos, false)

		if cell_obj.cell_type == CellObject.CellType.COVER:
			dict_pos_and_cell_cover[cell_obj.grid_pos] = cell_obj
			dict_pos_and_cell_cover[cell_obj.comp_wall.get_connected_cell_pos()] = cell_obj
			_enable_connection(cell_obj, false)

		if cell_obj.cell_type == CellObject.CellType.DOOR:
			dict_pos_and_cell_door[cell_obj.grid_pos] = cell_obj
			dict_pos_and_cell_door[cell_obj.comp_wall.get_connected_cell_pos()] = cell_obj
			open_door(cell_obj, cell_obj.comp_visual.opened)

		if cell_obj.comp_interactable:
			cell_obj.comp_interactable.on_hover_obj.connect(_on_hover_obj)


func _on_cell_broke(cell: CellObject):
	if cell.cell_type == CellObject.CellType.COVER:
		remove_cover(cell)
	elif cell.cell_type == CellObject.CellType.OBSTACLE:
		remove_obstacle(cell)


func remove_cover(cell: CellObject):
	dict_pos_and_cell_cover.erase(cell.grid_pos)
	dict_pos_and_cell_cover.erase(cell.comp_wall.get_connected_cell_pos())

	_enable_connection(cell, true, true)

	cell.queue_free()


func remove_obstacle(cell: CellObject):
	_enable_point_by_pos(cell.grid_pos, true, true)
	dict_pos_and_cell_obstacle.erase(cell.grid_pos)

	cell.queue_free()


func get_path_to_point(from: Vector2i, to: Vector2i, open_doors: bool = false) -> PathData:
	if not is_point_walkable(to):
		return null

	var from_id = astar.get_closest_point(from)
	var to_id = astar.get_closest_point(to)

	var opened_doors = null
	if open_doors:
		opened_doors = open_all_closest_door()

	var path_data = PathData.new()
	path_data.path.assign(astar.get_point_path(from_id, to_id))

	if open_doors:
		close_doors(opened_doors)

		for point in path_data.path:
			if dict_pos_and_cell_door.has(point):
				var door_cell_obj = dict_pos_and_cell_door[point]
				if not is_door_opened(door_cell_obj) and not path_data.doors.values().has(door_cell_obj):
					path_data.doors[point] = door_cell_obj

	return path_data


func open_all_closest_door() -> Array[CellObject]:
	var opened_doors: Array[CellObject] = []

	for door in dict_pos_and_cell_door.values():
		if not is_door_opened(door):
			open_door(door, true)
			opened_doors.append(door)

	return opened_doors


func close_doors(doors: Array[CellObject]):
	for door in doors:
		open_door(door, false)


func is_point_walkable(grid_pos : Vector2i) -> bool:
	var cell_obj: CellObject = get_cell_by_pos(grid_pos)
	var is_cell_walk = is_pos_walk(grid_pos)
	return (is_cell_walk and cell_obj == null) or (is_cell_walk and cell_obj and cell_obj.comp_walkable)


func has_path(from: Vector2i, to: Vector2i, open_doors: bool = false) -> bool:
	var path_data: PathData = get_path_to_point(from, to, open_doors)
	return path_data and not path_data.is_empty and path_data.path[-1] == to


func get_unit_on_cell(grid_pos: Vector2i) -> Unit:
	var all_units = GlobalUnits.units

	for unit in all_units.values():
		var unit_obj: UnitObject = unit.unit_object
		var unit_pos: Vector2i = unit_obj.grid_pos
		if grid_pos == unit_pos:
			return unit

	return null


func get_walkable_cells(unit_grid_pos: Vector2i, max_distance: int) -> Array[Vector2i]:
	if max_distance == 1:
		return []

	var from_x : int = unit_grid_pos.x - max_distance
	var to_x : int   = unit_grid_pos.x + max_distance
	var from_y : int = unit_grid_pos.y - max_distance
	var to_y : int   = unit_grid_pos.y + max_distance

	var walkable_cells: Array[Vector2i]

	for x in range(from_x, to_x + 1):
		for y in range(from_y, to_y + 1):
			var grid_pos = Vector2i(x, y)
			if grid_pos == unit_grid_pos:
				continue

			if get_unit_on_cell(grid_pos) != null:
				continue

			if not is_point_walkable(grid_pos):
				continue

			if not has_path(unit_grid_pos, grid_pos):
				continue

			if get_path_to_point(unit_grid_pos, grid_pos).path.size() <= max_distance:
				walkable_cells.push_back(grid_pos)

	return walkable_cells


func draw_walking_cells(grid_poses: Array[Vector2i]):
	clear_walking_cells()

	for grid_pos in grid_poses:
		spawned_walk_hints.append(_spawn_hint(walkable_hint_cell_scene, grid_pos))


func draw_damage_hints(grid_poses: Array[Vector2i]):
	clear_damage_hints()

	for grid_pos in grid_poses:
		spawned_damage_hints.append(_spawn_hint(cell_damage_hint_scene, grid_pos))


func clear_walking_cells():
	for tile in spawned_walk_hints:
		tile.queue_free()

	spawned_walk_hints.clear()


func clear_damage_hints():
	for hint in spawned_damage_hints:
		hint.queue_free()

	spawned_damage_hints.clear()


func _spawn_hint(scene: PackedScene, grid_pos) -> Node2D:
	var spawned: Node2D = scene.instantiate()
	root_walk_hint.add_child(spawned)
	spawned.position = Globals.convert_to_cell_pos(grid_pos)

	return spawned


func is_unit_in_cover(unit_pos: Vector2, cell_cover: CellObject) -> bool:
	var unit_grid_pos = Globals.convert_to_grid_pos(unit_pos)

	if cell_cover.cell_type != CellObject.CellType.COVER:
		printerr("cell is not cover!")
		return false

	return unit_grid_pos == cell_cover.grid_pos or unit_grid_pos == cell_cover.comp_wall.get_connected_cell_pos()


func is_point_has_cover(grid_pos: Vector2i) -> bool:
	var cell_object = get_cell_by_pos(grid_pos)
	if cell_object == null:
		return false

	return cell_object.cell_type == CellObject.CellType.COVER


func get_covers_in_points(points: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i]
	for point in points:
		if is_point_has_cover(point):
			result.append(point)

	return result


func get_cell_id_by_grid_pos(grid_pos: Vector2) -> int:
	var cell_id := astar.get_closest_point(grid_pos, true)
	return cell_id


func get_cell_by_pos(grid_pos: Vector2i) -> CellObject:
	if dict_pos_and_cell_cover.has(grid_pos):
		return dict_pos_and_cell_cover[grid_pos]

	if dict_pos_and_cell_obstacle.has(grid_pos):
		return dict_pos_and_cell_obstacle[grid_pos]

	if dict_pos_and_cell_wall.has(grid_pos):
		return dict_pos_and_cell_wall[grid_pos]

	return null


func is_pos_walk(grid_pos: Vector2i) -> bool:
	return walk_grid_poses.has(grid_pos)


func get_cells_by_pattern(grid_pos_center: Vector2i, pattern_cells: Array[Vector2i]) -> Array[CellInfo]:
	var result: Array[CellInfo] = []

	for cell_offset in pattern_cells:
		var grid_pos = grid_pos_center + cell_offset
		var cell_info = get_cell_info(grid_pos)
		result.push_back(cell_info)

	return result


func get_grid_poses_by_pattern(grid_pos_center: Vector2i, pattern_cells: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i]
	for cell in get_cells_by_pattern(grid_pos_center, pattern_cells):
		result.append(cell.grid_pos)

	return result


func can_open_door(cell: CellObject, unit_object: UnitObject) -> bool:
	if cell.cell_type != CellObject.CellType.DOOR:
		printerr("cell is not door!")
		return false

	return unit_object.grid_pos == cell.grid_pos or unit_object.grid_pos == cell.comp_wall.get_connected_cell_pos()


func is_door_opened(cell: CellObject) -> bool:
	if cell.cell_type != CellObject.CellType.DOOR:
		printerr("its not door")
		return false

	var first_cell_id := get_cell_id_by_grid_pos(cell.grid_pos)
	var second_cell_id := get_cell_id_by_grid_pos(cell.comp_wall.get_connected_cell_pos())

	return astar.are_points_connected(first_cell_id, second_cell_id)


func open_door(cell: CellObject, open: bool, update_fog: bool = false):
	if cell.cell_type != CellObject.CellType.DOOR:
		printerr("its not door")
		return

	_enable_connection(cell, open, true)
	cell.comp_visual.opened = open
	cell.comp_wall.enable_wall_collision(not open)

	if update_fog:
		fog_of_war.update_fog_for_all(true)


func get_cell_info(grid_pos: Vector2i) -> CellInfo:
	var cell_obj := get_cell_by_pos(grid_pos)
	var unit_on_cell: Unit = get_unit_on_cell(grid_pos)
	var unit_id := unit_on_cell.id if unit_on_cell != null else -1
	var info = CellInfo.new(grid_pos, cell_obj, unit_id)

	if hovered_obj:
		info.cell_obj = hovered_obj
		info.not_cell = true

	if is_pos_walk(grid_pos):
		info.is_ground = true

	return info


func _enable_point_by_pos(grid_pos: Vector2i, enable: bool, update_debug: bool = false):
	var cell_id := get_cell_id_by_grid_pos(grid_pos)
	astar.set_point_disabled(cell_id, !enable)

	if update_debug:
		_draw_debug()


func _enable_connection(cell: CellObject, enable: bool, update_debug: bool = false):
	var first_cell_id := get_cell_id_by_grid_pos(cell.grid_pos)
	var second_cell_id := get_cell_id_by_grid_pos(cell.comp_wall.get_connected_cell_pos())

	if enable:
		astar.connect_points(first_cell_id, second_cell_id)
		print("connected {0}, {1}".format([first_cell_id, second_cell_id]))
	else:
		astar.disconnect_points(first_cell_id, second_cell_id)
		print("disconected {0}, {1}".format([first_cell_id, second_cell_id]))

	if update_debug:
		_draw_debug()


func _on_hover_obj(cell_obj: CellObject):
	if (not hovered_obj and cell_obj) or (hovered_obj and not cell_obj): # it need for invoke hover event
		prev_hovered_cell_pos = Vector2i.ZERO

	hovered_obj = cell_obj
	print("hovered cell obj {0}".format([cell_obj]))


func _on_input_system_on_mouse_hover(mouse_pos: Vector2) -> void:
	var grid_pos := Globals.convert_to_grid_pos(mouse_pos)
	var info := get_cell_info(grid_pos)

	if info.cell_obj != null and prev_hovered_cell_pos == info.grid_pos:
		return

	prev_hovered_cell_pos = info.grid_pos if info.is_ground or info.cell_obj else Vector2.ZERO
	cell_hint.position = Globals.convert_to_cell_pos(prev_hovered_cell_pos)

	if info.not_cell:
		cell_hint.position = Vector2i.ZERO

	GlobalBus.on_hovered_cell.emit(info)


func _on_input_system_on_mouse_click(mouse_pos: Vector2) -> void:
	var grid_pos := Globals.convert_to_grid_pos(mouse_pos)
	var info := get_cell_info(grid_pos)

	GlobalBus.on_clicked_cell.emit(info)

	if info.cell_obj == null:
		print("clicked nowhere")
		return

	print("clicked on {0}".format([info.cell_obj]))


