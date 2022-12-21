extends Node2D
class_name UnitObject


@onready var main_sprite := $Sprite2d as Sprite2D

var unit_id = -1
var main_material: Material



func init_unit(unit_id, unit_data) -> void:
	self.unit_id = unit_id


func _ready() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)

	main_sprite.material = main_sprite.material.duplicate()
	main_material = main_sprite.material

	mark_selected(false)


func _on_unit_died(unit_id, unit_id_killer):
	if self.unit_id != unit_id:
		return

	queue_free()


func mark_selected(is_selected: bool):
	main_material.set_shader_parameter("line_thickness", 1.0 if is_selected else 0.0)
