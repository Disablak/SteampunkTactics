extends Node2D


@export var cell_objects : Array[CellObject]

@onready var tilemap : TileMap = $TileMap as TileMap

const TILEMAP_LAYER = 0

var astar : AStar2D = AStar2D.new()


# Called when the node enters the scene tree for the first time.
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


func get_path_to_point(from : Vector2i, to : Vector2i) -> PackedVector2Array:
	if not is_point_walkable(to):
		return PackedVector2Array()
	
	var from_id = astar.get_closest_point(from)
	var to_id = astar.get_closest_point(to)
	
	return astar.get_point_path(from_id, to_id)


func get_cell_obj(cell_pos : Vector2i) -> CellObject:
	for cell_obj in cell_objects:
		var atlas_coords := tilemap.get_cell_atlas_coords(TILEMAP_LAYER, cell_pos)
		if atlas_coords == cell_obj.atlas_coords:
			return cell_obj
	
	return null


func is_point_walkable(cell_pos : Vector2i) -> bool:
	if tilemap.get_used_cells(TILEMAP_LAYER).has(cell_pos):
		var cell_obj := get_cell_obj(cell_pos)
		return cell_obj != null and cell_obj.obj_type == CellObject.AtlasObjectType.GROUND
	
	return false
	
