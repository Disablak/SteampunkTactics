class_name CellObject
extends Node2D


enum CellType {NONE, GROUND, WALL, COVER, OBSTACLE, DOOR}

@onready var comp_visual: CellCompVisual = $CompVisual as CellCompVisual
@onready var comp_wall: CellCompWall = $CompWall as CellCompWall
@onready var comp_walkable: CellCompWalkable = $CompWalkable as CellCompWalkable
@onready var comp_interactable: CellCompInteractable = $CompInteractable as CellCompInteractable
@onready var comp_obstacle: CellCompObstacle = $CompObstacle as CellCompObstacle


var cell_type: CellType:
	get:
		if comp_wall and comp_wall.cover:
			return CellType.COVER
		if comp_wall and comp_wall.door:
			return CellType.DOOR
		if comp_wall:
			return CellType.WALL
		if comp_walkable:
			return CellType.GROUND
		if comp_obstacle:
			return CellType.OBSTACLE

		return CellType.NONE


var grid_pos: Vector2i:
	get: return Globals.convert_to_grid_pos(position)

var origin_pos: Vector2:
	get: return comp_visual.origin_pos if comp_visual else Vector2.ZERO

func _to_string() -> String:
	return CellType.keys()[cell_type]
