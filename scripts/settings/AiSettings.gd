class_name AiSettings
extends Resource


@export var walking_zone_node_path: NodePath
@export var patrul_zones_paths: Array[NodePath]

var walking_zone_rect: Rect2i
var walking_zone_cells: Array[Vector2i]

var patrul_zones_id_and_cells = {} # zone id and grir cells
var cur_target_zone_id = 0
var walk_pos_to_patrul_zone: Vector2i = Vector2i.ZERO

var cover_path_data: PathData = null
var visible_enemies: Array[Unit]

var shortest_path_to_enemy: PathData
var enemy_stand_near: int = -1


func init(node_zone, patrul_zones: Array[Node2D]):
	_init_walking_zone(node_zone)
	_init_patrul_zones(patrul_zones)


func get_cur_target_patrul_zone_points() -> Array[Vector2i]:
	return patrul_zones_id_and_cells[cur_target_zone_id]


func patrul_next_zone():
	cur_target_zone_id = wrapi(cur_target_zone_id + 1, 0, patrul_zones_id_and_cells.size())


func _init_walking_zone(node_zone):
	if node_zone == null:
		return

	walking_zone_cells = _get_cells_by_node(node_zone)


func _init_patrul_zones(patrul_zones: Array[Node2D]):
	if patrul_zones.size() == 0:
		return

	var id = 0
	for zone in patrul_zones:
		patrul_zones_id_and_cells[id] = _get_cells_by_node(zone);
		id += 1


func _get_cells_by_node(node: Node2D) -> Array[Vector2i]:
	var zone_rect = Rect2i(Globals.convert_to_grid_pos(node.position + Globals.CELL_OFFSET), node.scale)
	var result: Array[Vector2i]
	for x in zone_rect.size.x:
			for y in zone_rect.size.y:
				result.append(zone_rect.position + Vector2i(x, y))

	return result
