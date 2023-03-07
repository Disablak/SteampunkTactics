class_name CellCompVisual
extends Sprite2D


@onready var original_texture: Texture2D = texture

@export var opened_texture: Texture2D
@export var opened: bool = false:
	set(value):
		texture = opened_texture if value else original_texture
		opened = value

var origin_offset := 0

var visual_ordering: int:
	get:
		return z_index
	set(value):
		z_index = value

var origin_pos: Vector2:
	get: return get_parent().position + Vector2(8, origin_offset)


func make_transparent(enable: bool):
	modulate.a = 0.5 if enable else 1.0


func _ready() -> void:
	origin_offset = Globals.get_height_of_obj(texture.region) + position.y + offset.y
