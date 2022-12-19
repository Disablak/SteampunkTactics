class_name CellInfo
extends RefCounted


var cell_pos: Vector2
var cell_obj: CellObject
var unit_id: int


func reset():
	cell_pos = Vector2.ZERO
	cell_obj = null
	unit_id = -1
