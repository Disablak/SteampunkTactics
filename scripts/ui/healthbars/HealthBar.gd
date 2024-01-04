class_name HealthBar
extends Sprite2D


@export var sprite_full_texture: Texture2D
@export var sprite_half_texture: Texture2D

@onready var line_health: Node2D = $LineHealth
@onready var line_armor: Node2D = $LineArmor
@onready var back: Node2D = $Back


var _start_line_width: float
var _start_pos: Vector2


func _ready() -> void:
	_start_line_width = line_health.scale.x
	_start_pos = position


func update_healthar(value_0_cur: float, value_0_max: float, value_1_cur: float, value_1_max: float):
	line_health.scale.x = (value_0_cur / value_0_max) * _start_line_width

	if value_1_cur <= 0:
		texture = sprite_half_texture
		line_armor.visible = false
		back.scale.y = 0.187
		position = _start_pos + Vector2(0, 2)
	else:
		line_armor.scale.x = (value_1_cur / value_1_max) * _start_line_width


