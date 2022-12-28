class_name CellObject
extends Node2D


enum CellType {NONE, GROUND, WALL, COVER, OBSTACLE}

@export var cell_type: CellType = CellType.NONE
@export var health: int = -1
@export_range(0.0, 0.5, 0.05) var shoot_debaf: float = 0.0

var connected_cells: Array[CellObject]


func _ready() -> void:
	for child in get_children():
		if child is CellObject:
			connected_cells.append(child)
			print("Child connected: {0}".format([child]))


func set_damage(damage: int = 1):
	if health == -1:
		return

	health -= damage
	if health <= 0:
		_break_cell()


func _break_cell():
	GlobalBus.on_cell_broke.emit(self)
	print("cell is broke")


func get_type_string() -> String:
	return CellType.keys()[cell_type]
