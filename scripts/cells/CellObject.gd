class_name CellObject
extends Node2D


signal on_click_obj(cell_obj: CellObject)
signal on_hover_obj(cell_obj: CellObject)

enum CellType {NONE, GROUND, WALL, COVER, OBSTACLE, DOOR}
enum WallType {NONE, LEFT, RIGHT, TOP, BOT}

@onready var main_sprite := $VisualObject as Sprite2D

@export var cell_type: CellType = CellType.NONE
@export var is_walkable := false
@export var health: int = -1
@export_range(0.0, 0.5, 0.05) var shoot_debaf: float = 0.0
@export var opened: bool = false:
	set(value):
		if main_sprite:
			main_sprite.texture = opened_texture if value else original_texture

@export var opened_texture: Texture2D
@export var show_visual_if_front_visible := false
@export var wall_type: WallType = WallType.NONE

var destroyed := false
var connected_cells_pos: Array[Vector2i]
var area2d: Area2D = null
var collsition_shape: CollisionShape2D
var origin_offset := 0
var original_texture: Texture2D

var grid_pos: Vector2i:
	get: return Globals.convert_to_grid_pos(position)

var origin_pos: Vector2:
	get: return position + Vector2(8, origin_offset)

var visual_ordering: int:
	get:
		if main_sprite == null:
			printerr("main sprite not found")
			return -1

		return main_sprite.z_index
	set(value):
		if main_sprite == null:
			printerr("main sprite not found")
			return

		main_sprite.z_index = value

var is_interactable: bool:
	get:
		return cell_type == CellType.DOOR


var is_cell_visible: bool = true:
	get: return is_cell_visible
	set(value):
		is_cell_visible = value
		if main_sprite:
			main_sprite.visible = value


func _ready() -> void:
	for child in get_children():
		if child is CellObject:
			connected_cells_pos.append(Globals.convert_to_grid_pos(position + child.position))

	area2d = find_child("Area2D", false, false) as Area2D
	collsition_shape = find_child("CollisionShape2D", true, false)

	if area2d:
		area2d.mouse_entered.connect(_on_mouse_hover)
		area2d.mouse_exited.connect(_on_mouse_exit)

	if not main_sprite:
		return

	origin_offset = Globals.get_height_of_obj(main_sprite.texture.region) + main_sprite.position.y + main_sprite.offset.y
	original_texture = main_sprite.texture


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


func make_transparent(enable: bool):
	main_sprite.modulate.a = 0.5 if enable else 1.0


func _break_cell():
	print("cell is broke")


func _to_string() -> String:
	return CellType.keys()[cell_type]


func _on_mouse_hover():
	if is_interactable:
		on_hover_obj.emit(self)


func _on_mouse_exit():
	if is_interactable:
		on_hover_obj.emit(null)

