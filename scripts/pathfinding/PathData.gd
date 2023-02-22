class_name PathData
extends RefCounted


var target_point: Vector2i
var path: Array[Vector2i]
var unit_id: int = -1
var doors = {} # pos and cell object

var is_empty: bool:
	get: return path == null or path.size() <= 1
