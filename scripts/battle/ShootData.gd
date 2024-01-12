class_name ShootData
extends RefCounted


class ShootPoint:
	var point: Vector2
	var game_object: GameObject

	func _init(p: Vector2, go: GameObject) -> void:
		point = p
		game_object = go


var shoot_points: Array[ShootPoint]


func is_hit_in_unit_object() -> bool:
	for shoot_point in shoot_points:
		if shoot_point.game_object is UnitObject:
			return true

		continue

	return false
