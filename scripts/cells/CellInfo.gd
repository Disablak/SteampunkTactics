class_name CellInfo
extends RefCounted


var cell_pos: Vector2
var cell_obj: CellObject
var unit_id: int


func _init(cell_pos: Vector2, cell_obj: CellObject, unit_id: int) -> void:
	self.cell_pos = cell_pos
	self.cell_obj = cell_obj
	self.unit_id = unit_id


func reset():
	cell_pos = Vector2.ZERO
	cell_obj = null
	unit_id = -1
