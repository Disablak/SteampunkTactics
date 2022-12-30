class_name CellObject
extends Node2D


enum CellType {NONE, GROUND, WALL, COVER, OBSTACLE}

@export var cell_type: CellType = CellType.NONE
@export var health: int = -1
@export_range(0.0, 0.5, 0.05) var shoot_debaf: float = 0.0

var destroyed := false
var connected_cells_pos: Array[Vector2]
var collsition_shape: CollisionShape2D


func _ready() -> void:
	for child in get_children():
		if child is CellObject:
			connected_cells_pos.append(Globals.snap_to_cell_pos(position + child.position))

	collsition_shape = find_child("CollisionShape2D", true, false)


func set_damage(damage: int = 1):
	if health == -1:
		return

	health -= damage
	if health > 0:
		return

	destroyed = true
	collsition_shape.disabled = true

	GlobalBus.on_cell_broke.emit(self)


func _break_cell():

	print("cell is broke")


func get_type_string() -> String:
	return CellType.keys()[cell_type]
