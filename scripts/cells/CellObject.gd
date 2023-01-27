class_name CellObject
extends Node2D


enum CellType {NONE, GROUND, WALL, COVER, OBSTACLE}

@export var cell_type: CellType = CellType.NONE
@export var is_walkable := false
@export var health: int = -1
@export_range(0.0, 0.5, 0.05) var shoot_debaf: float = 0.0

var destroyed := false
var connected_cells_pos: Array[Vector2i]
var collsition_shape: CollisionShape2D

var grid_pos: Vector2i:
	get:
		return Globals.convert_to_grid_pos(position)


func _ready() -> void:
	for child in get_children():
		if child is CellObject:
			connected_cells_pos.append(Globals.convert_to_grid_pos(position + child.position))

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


func get_cover_angle(pos: Vector2i) -> int:
	if cell_type != CellType.COVER:
		printerr("Its not cover")
		return -1

	# todo fix this hardcode!
	if pos == grid_pos:
		return 0
	elif pos == connected_cells_pos[0]:
		return 180
	else:
		printerr("pos is not cover!")
		return -1



func _break_cell():
	print("cell is broke")


func get_type_string() -> String:
	return CellType.keys()[cell_type]
