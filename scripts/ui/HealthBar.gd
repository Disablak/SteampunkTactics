class_name HealthBar
extends Sprite2D


@export var sprite_full_texture: Texture2D
@export var sprite_half_texture: Texture2D

@onready var line_health: Node2D = $LineHealth
@onready var line_armor: Node2D = $LineArmor
@onready var back: Node2D = $Back


var _unit_id: int
var _start_line_width: float


func _ready() -> void:
	_start_line_width = line_health.scale.x

	GlobalBus.on_unit_stat_changed.connect(_on_unit_stat_changed)


func init(unit_id: int):
	_unit_id = unit_id

	await get_tree().process_frame
	_update_healthbar(unit_id)


func _update_healthbar(unit_id):
	if unit_id != _unit_id:
		return

	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_id)
	line_health.scale.x = (unit.unit_data.cur_health / unit.unit_data.max_health) * _start_line_width

	if unit.unit_data.cur_armor <= 0:
		texture = sprite_half_texture
		line_armor.visible = false
		back.scale.y = 0.187
		position += Vector2(0, 2)
	else:
		line_armor.scale.x = (unit.unit_data.cur_armor / unit.unit_data.max_armor) * _start_line_width


func _on_unit_stat_changed(unit_id: int, stat: UnitStat):
	_update_healthbar(unit_id)
