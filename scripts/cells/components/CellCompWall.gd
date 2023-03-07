class_name CellCompWall
extends Area2D


const WALL_LAYER: int = 5
enum WallType {NONE, LEFT, RIGHT, TOP, BOT}

@export var wall_type: WallType = WallType.NONE

@export var cover := false
@export var door := false
@export var health: int = -1
@export_range(0.0, 0.5, 0.05) var shoot_debaf: float = 0.0

@onready var collsition_shape: CollisionShape2D = $CollisionShape2D

var destroyed := false


func set_damage(damage: int = 1):
	if health == -1:
		return

	health -= damage
	if health > 0:
		return

	destroyed = true
	collsition_shape.disabled = true

	GlobalBus.on_cell_broke.emit(get_parent())


func get_connected_cell_pos() -> Vector2i:
	if wall_type == WallType.LEFT or wall_type == WallType.RIGHT:
		return get_parent().grid_pos + Vector2i(-1, 0)
	elif wall_type == WallType.TOP or wall_type == WallType.BOT:
		return get_parent().grid_pos + Vector2i(0, -1)

	printerr("wall type not selected!")
	return Vector2i.ZERO


func get_cover_angle(pos: Vector2i) -> int:
	if not cover:
		printerr("Its not cover")
		return -1

	# TODO fix this hardcode!
	if pos == get_parent().grid_pos:
		return 0
	elif pos == get_connected_cell_pos():
		return 180
	else:
		printerr("pos is not cover!")
		return -1


func enable_wall_collision(enable):
	set_collision_layer_value(WALL_LAYER, enable)
