class_name CoverPoints
extends Node2D


@export var point_radius: int = 8
@export var interactable_static_body: InteractableStaticBody

var _points: Array[Node2D]


func _ready() -> void:
	_points.assign(get_children())


func is_unit_in_cover(unit: Unit) -> bool:
	for point in _points:
		if unit.origin_pos.distance_to(point.global_position) <= point_radius:
			return true

	return false


func enable_conver_collision():
	interactable_static_body.enable_collision()


func disable_cover_collision():
	interactable_static_body.disable_collision()
