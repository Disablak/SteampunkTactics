class_name ShootEffect
extends RefCounted


const BULLET_SPEED = 500
const SHOOT_MISS_POS_LERP = [0.0, 0.1, 0.2, 0.3, 0.7, 0.8, 0.9, 1.0]
const MISSED_BULLET_DISTANCE = 1000
const MISS_MAX_BULLET_OFFSET = 5

var _bullet_scene: PackedScene
var _bullet_root: Node2D


func _init(bullet_scene: PackedScene, bullet_root: Node2D):
	_bullet_scene = bullet_scene
	_bullet_root = bullet_root


func create_bullet_and_tween(tween: Tween, from: Vector2, to: Vector2):
	var new_instance: Node2D = _bullet_scene.instantiate()
	_bullet_root.add_child(new_instance)

	new_instance.position = from
	new_instance.look_at(to)

	var distance = from.distance_to(to)
	var time = distance / BULLET_SPEED

	tween.tween_property(new_instance, "position", to, time)
	tween.tween_callback(new_instance.queue_free)
	await tween.finished


func play(tween: Tween, from: Vector2, to: Vector2, hit_type: ShootingModule.HitType, cover_pos: Vector2, random_obs: CellObject):
	var from_pos: Vector2 = from
	var to_pos: Vector2 = to

	if hit_type == ShootingModule.HitType.HIT_IN_COVER:
		to_pos = cover_pos
	elif hit_type == ShootingModule.HitType.HIT_IN_OBS:
		to_pos = random_obs.position
	elif hit_type == ShootingModule.HitType.MISS:
		to_pos = from_pos + _get_little_wrong_shoot_direction(to_pos - from_pos)

	await create_bullet_and_tween(tween, from_pos, to_pos)


func _get_little_wrong_shoot_direction(shoot_vector: Vector2) -> Vector2:
	var dir: Vector2 = shoot_vector.normalized()
	var degree = Vector2.RIGHT.angle_to(dir) + PI / 2
	var vec_perpen = Vector2.from_angle(degree) * MISS_MAX_BULLET_OFFSET

	var random_offset = lerp(-vec_perpen, vec_perpen, SHOOT_MISS_POS_LERP.pick_random())
	var with_big_length: Vector2 = (shoot_vector + random_offset).normalized() * MISSED_BULLET_DISTANCE

	return with_big_length
