@tool
class_name AiSettings
extends Resource


@export var node_path: NodePath

var walking_zone_rect: Rect2i
var walking_zone_cells: Array[Vector2i]


func init(node_zone: Node2D):
	walking_zone_rect = Rect2i(Globals.convert_to_grid_pos(node_zone.position + Globals.CELL_OFFSET), node_zone.scale)

	for x in walking_zone_rect.size.x:
			for y in walking_zone_rect.size.y:
				walking_zone_cells.append(walking_zone_rect.position + Vector2i(x, y))
