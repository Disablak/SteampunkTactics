class_name CellObject
extends Node2D


signal on_click_obj(cell_obj: CellObject)
signal on_hover_obj(cell_obj: CellObject)

enum CellType {NONE, GROUND, WALL, COVER, OBSTACLE, DOOR}

@export var cell_type: CellType = CellType.NONE
@export var is_walkable := false
@export var health: int = -1
@export_range(0.0, 0.5, 0.05) var shoot_debaf: float = 0.0

var destroyed := false
var connected_cells_pos: Array[Vector2i]
var area2d: Area2D = null
var collsition_shape: CollisionShape2D

var grid_pos: Vector2i:
	get: return Globals.convert_to_grid_pos(position)

var can_use: bool:
	get: return cell_type == CellType.DOOR or cell_type == CellType.COVER or cell_type == CellType.OBSTACLE or cell_type == CellType.WALL


func _ready() -> void:
	for child in get_children():
		if child is CellObject:
			connected_cells_pos.append(Globals.convert_to_grid_pos(position + child.position))

	area2d = find_child("Area2D", false, false) as Area2D
	collsition_shape = find_child("CollisionShape2D", true, false)

	if area2d:
		area2d.input_event.connect(_on_mouse_click)
		area2d.mouse_entered.connect(_on_mouse_hover)


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

	# TODO fix this hardcode!
	if pos == grid_pos:
		return 0
	elif pos == connected_cells_pos[0]:
		return 180
	else:
		printerr("pos is not cover!")
		return -1



func _break_cell():
	print("cell is broke")


func _to_string() -> String:
	return CellType.keys()[cell_type]


func _on_mouse_click(viewport, event, id):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if can_use:
			on_click_obj.emit(self)


func _on_mouse_hover():
	if can_use:
		on_hover_obj.emit(self)

