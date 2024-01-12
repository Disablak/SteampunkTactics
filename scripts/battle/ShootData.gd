class_name ShootData
extends RefCounted


const REFLECT_COLLISION_GROUP = "collision_reflect"


class ShootPoint:
	var point: Vector2
	var game_object: GameObject
	var ray_dic: Dictionary

	var is_reflected: bool:
		get: return not ray_dic.is_empty() and ray_dic.collider.is_in_group(REFLECT_COLLISION_GROUP)

	func _init(p: Vector2, go: GameObject, ray: Dictionary) -> void:
		point = p
		game_object = go
		ray_dic = ray



var shoot_points: Array[ShootPoint]


func is_hit_in_unit_object() -> bool:
	for shoot_point in shoot_points:
		if shoot_point.game_object is UnitObject:
			return true

		continue

	return false


func get_unit_object() -> UnitObject:
	for shoot_point in shoot_points:
		if shoot_point != null and shoot_point.game_object is UnitObject:
			return shoot_point.game_object

	return null
