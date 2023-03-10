class_name CellObject
extends Node2D


enum CellType {NONE, GROUND, WALL, COVER, OBSTACLE, DOOR}

@onready var comp_visual: CellCompVisual = $CompVisual as CellCompVisual
@onready var comp_wall: CellCompWall = $CompWall as CellCompWall
@onready var comp_walkable: CellCompWalkable = $CompWalkable as CellCompWalkable
@onready var comp_interactable: CellCompInteractable = $CompInteractable as CellCompInteractable
@onready var comp_obstacle: CellCompObstacle = $CompObstacle as CellCompObstacle
@onready var comp_health: CellCompHealth = $CompHealth as CellCompHealth


var cell_type: CellType:
	get:
		if comp_wall and comp_wall.cover:
			return CellType.COVER
		if comp_wall and comp_wall.door:
			return CellType.DOOR
		if comp_wall:
			return CellType.WALL
		if comp_obstacle:
			return CellType.OBSTACLE
		if comp_walkable:
			return CellType.GROUND

		return CellType.NONE


var grid_pos: Vector2i:
	get: return Globals.convert_to_grid_pos(position)

var origin_pos: Vector2:
	get: return comp_visual.origin_pos if comp_visual else Vector2.ZERO

var visual_pos: Vector2:
	get: return position + Globals.CELL_OFFSET

var visual_ordering: int:
	get:
		if comp_visual:
			return comp_visual.visual_ordering
		return -1
	set(value):
		if comp_visual:
			comp_visual.visual_ordering = value


func make_transparent(enable):
	if comp_visual:
		comp_visual.make_transparent(enable)


func _to_string() -> String:
	return CellType.keys()[cell_type]
