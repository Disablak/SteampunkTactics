class_name CellInfo
extends RefCounted


var grid_pos: Vector2i
var cell_obj: CellObject
var is_ground: bool = false
var unit_id: int
var not_cell: bool = false


func _init(grid_pos: Vector2i, cell_obj: CellObject, unit_id: int) -> void:
	self.grid_pos = grid_pos
	self.cell_obj = cell_obj
	self.unit_id = unit_id
