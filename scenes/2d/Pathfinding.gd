class_name Pathfinding
extends Node2D


signal on_hovered_cell(hover_info)
signal on_clicked_cell(hover_info)

@export var cell_objects : Array[CellObject]
@export var tile_node_scene: PackedScene
@export var tile_walkable_scene: PackedScene

@onready var tilemap : TileMap = $TileMap as TileMap

const TILEMAP_LAYER = 0

var astar : AStar2D = AStar2D.new()
var spawned_walking_tiles = Array()


func _ready() -> void:
	var all_cell_pos := tilemap.get_used_cells(TILEMAP_LAYER)
	
	# add points to astar
	for cell_pos in all_cell_pos:
		var cell_obj := get_cell_obj(cell_pos)
		if cell_obj != null and cell_obj.obj_type == CellObject.AtlasObjectType.GROUND:
			var id = astar.get_available_point_id()
			astar.add_point(id, cell_pos)
	
	# connect ground cells
	for cell_pos in all_cell_pos:
		var cell_obj := get_cell_obj(cell_pos)
		if cell_obj == null or cell_obj.obj_type != CellObject.AtlasObjectType.GROUND:
			continue
			
		var cur_cell_id = astar.get_closest_point(cell_pos)
		
		for offset in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var potential_ground_coords : Vector2i = cell_pos + offset
			if not all_cell_pos.has(potential_ground_coords):
				continue
			
			var potential_cell_obj := get_cell_obj(potential_ground_coords)
			
			if potential_cell_obj != null and potential_cell_obj.obj_type == CellObject.AtlasObjectType.GROUND:
				var potential_cell_id = astar.get_closest_point(potential_ground_coords)
				if not astar.are_points_connected(cur_cell_id, potential_cell_id):
					astar.connect_points(cur_cell_id, potential_cell_id)
					print("connected {0} and {1}".format([cur_cell_id, potential_cell_id]))
	
	spawn_walls()


func spawn_walls():
	for cell_pos in tilemap.get_used_cells(TILEMAP_LAYER):
		var cell_obj := get_cell_obj(cell_pos)
		if cell_obj != null and cell_obj.obj_type == CellObject.AtlasObjectType.WALL:
			var spawned_wall: Node2D = tile_node_scene.instantiate()
			add_child(spawned_wall)
			spawned_wall.position = Globals.convert_to_rect_pos(cell_pos)


func get_path_to_point(from : Vector2i, to : Vector2i) -> PackedVector2Array:
	if not is_point_walkable(to):
		return PackedVector2Array()
	
	var from_id = astar.get_closest_point(from)
	var to_id = astar.get_closest_point(to)
	
	return astar.get_point_path(from_id, to_id)


func get_cell_obj(cell_pos : Vector2i) -> CellObject:
	for cell_obj in cell_objects:
		var atlas_coords := tilemap.get_cell_atlas_coords(TILEMAP_LAYER, cell_pos)
		var tile_data := tilemap.get_cell_tile_data(TILEMAP_LAYER, cell_pos)
		if atlas_coords == cell_obj.atlas_coords:
			return cell_obj
	
	return null


func is_point_walkable(cell_pos : Vector2i) -> bool:
	if tilemap.get_used_cells(TILEMAP_LAYER).has(cell_pos):
		var cell_obj := get_cell_obj(cell_pos)
		return cell_obj != null and cell_obj.obj_type == CellObject.AtlasObjectType.GROUND
	
	return false


func has_path(from: Vector2, to: Vector2) -> bool:
	var path: PackedVector2Array = get_path_to_point(from, to)
	return path.size() > 0 and path[path.size() - 1] == to


func get_unit_on_cell(cell_pos: Vector2) -> Unit:
	var all_units = GlobalUnits.units
	
	for unit in all_units.values():
		var unit_obj: UnitObject = unit.unit_object
		var unit_pos: Vector2 = unit_obj.position
		var unit_pos_cell = Globals.convert_to_tile_pos(unit_pos)
		
		if cell_pos == unit_pos_cell:
			return unit
	
	return null


func set_hover_info_cell_obj(hover_info):
	var cell_obj: CellObject = get_cell_obj(Globals.convert_to_tile_pos(hover_info.pos))
	hover_info.cell_obj = cell_obj
	return hover_info


func get_cell_pos(mouse_pos: Vector2):
	var convert


func get_walkable_cells(unit_pos: Vector2i, max_distance: int) -> PackedVector2Array:
	if max_distance == 1:
		return PackedVector2Array()
	
	var from_x : int = unit_pos.x - max_distance
	var to_x : int   = unit_pos.x + max_distance
	var from_y : int = unit_pos.y - max_distance
	var to_y : int   = unit_pos.y + max_distance
	
	var walkable_cells := PackedVector2Array()
	
	for x in range(from_x, to_x + 1):
		for y in range(from_y, to_y + 1):
			var cell_pos := Vector2i(x, y)
			if is_point_walkable(cell_pos):
				if has_path(unit_pos, cell_pos):
					if get_path_to_point(unit_pos, cell_pos).size() <= max_distance:
						walkable_cells.push_back(cell_pos)
	
	return walkable_cells


func draw_walking_cells(walking_cells: PackedVector2Array):
	clear_walking_cells()
	
	for cell_pos in walking_cells:
		var walkable: Node2D = tile_walkable_scene.instantiate()
		add_child(walkable)
		spawned_walking_tiles.push_back(walkable)
		walkable.position = Globals.convert_to_rect_pos(cell_pos)


func clear_walking_cells():
	for tile in spawned_walking_tiles:
		tile.queue_free()
	
	spawned_walking_tiles.clear()


func _on_input_system_on_mouse_hover(hover_info) -> void:
	on_hovered_cell.emit(set_hover_info_cell_obj(hover_info))


func _on_input_system_on_mouse_click(hover_info) -> void:
	hover_info = set_hover_info_cell_obj(hover_info)
	var unit_on_cell: Unit = get_unit_on_cell(Globals.convert_to_tile_pos(hover_info.pos))
	if unit_on_cell:
		hover_info.unit_id = unit_on_cell.id
	
	print("clicked on {0}".format([hover_info]))
	on_clicked_cell.emit(hover_info)


