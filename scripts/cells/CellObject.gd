class_name CellObject
extends Node2D


enum CellType {NONE, GROUND, WALL}

@export var cell_type : CellType = CellType.NONE


func get_type_string() -> String:
	return CellType.keys()[cell_type]
