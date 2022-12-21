class_name EffectManager
extends Node2D


@export var bullet_scene: PackedScene

const BULLET_SPEED = 1500
const SHOOT_MISS_POS_LERP = [0.0, 0.1, 0.2, 0.8, 0.9, 1.0]
const MISSED_BULLET_DISTANCE = 1000
const MISS_MAX_BULLET_OFFSET = 15


func shoot(from: Unit, to: Unit, is_hitted: bool):
	var new_instance: Node2D = bullet_scene.instantiate()
	add_child(new_instance)

	var from_pos: Vector2 = from.unit_object.position
	var to_pos: Vector2 = to.unit_object.position

	if not is_hitted:
		to_pos = from_pos + _get_little_wrong_shoot_direction(to_pos - from_pos)

	new_instance.position = from_pos
	new_instance.look_at(to_pos)

	var distance = from_pos.distance_to(to_pos)
	var time = distance / BULLET_SPEED

	var tween: Tween = create_tween()
	tween.tween_property(
		new_instance, "position",
		to_pos, time
	)
	tween.tween_callback(Callable(new_instance,"queue_free"))


func _get_little_wrong_shoot_direction(shoot_vector: Vector2) -> Vector2:
	var dir: Vector2 = shoot_vector.normalized()
	var degree = Vector2.RIGHT.angle_to(dir) + PI / 2
	var vec_perpen = Vector2.from_angle(degree) * MISS_MAX_BULLET_OFFSET

	var random_offset = lerp(-vec_perpen, vec_perpen, SHOOT_MISS_POS_LERP.pick_random())
	var with_big_length: Vector2 = (shoot_vector + random_offset).normalized() * MISSED_BULLET_DISTANCE

	return with_big_length
