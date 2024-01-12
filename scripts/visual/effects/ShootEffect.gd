class_name ShootEffect
extends RefCounted


const BULLET_SPEED = 400
const SHOOT_MISS_POS_LERP = [0.0, 0.1, 0.2, 0.3, 0.7, 0.8, 0.9, 1.0]
const MISSED_BULLET_DISTANCE = 1000
const MISS_MAX_BULLET_OFFSET = 5

var _tween: Tween
var _bullet_scene: PackedScene
var _bullet_root: Node2D
var _cur_bullet: Node2D
var _on_finish: Callable


func is_tweening() -> bool:
	return _tween and _tween.is_valid() and _tween.is_running()


func _init(bullet_scene: PackedScene, bullet_root: Node2D):
	_bullet_scene = bullet_scene
	_bullet_root = bullet_root


func tween_bullet(tween: Tween, shoot_data: ShootData, on_finish: Callable):
	_on_finish = on_finish
	_cur_bullet = _bullet_scene.instantiate()
	_bullet_root.add_child(_cur_bullet)
	_tween = tween
	_cur_bullet.position = shoot_data.shoot_points[0].point

	for i in shoot_data.shoot_points.size():
		if i + 1 >= shoot_data.shoot_points.size():
			break

		var from = shoot_data.shoot_points[i].point
		var to = shoot_data.shoot_points[i + 1].point

		_cur_bullet.look_at(to)

		var distance = from.distance_to(to)
		var time = distance / BULLET_SPEED

		_tween.tween_property(_cur_bullet, "position", to, time)

	#_tween.tween_property(_cur_bullet, "modulate:a", 0.0, 0.3)
	_tween.tween_callback(_on_finish_tween)


func _on_finish_tween():
	_cur_bullet.queue_free()

	if _on_finish:
		_on_finish.call()


func create_bullet_and_tween(tween: Tween, from: Vector2, to: Vector2, on_finish: Callable):
	var new_instance: Node2D = _bullet_scene.instantiate()
	_bullet_root.add_child(new_instance)

	new_instance.position = from
	new_instance.look_at(to)

	var distance = from.distance_to(to)
	var time = distance / BULLET_SPEED

	var _on_finish = func():
		new_instance.queue_free()
		if on_finish:
			on_finish.call()

	_tween = tween
	_tween.tween_property(new_instance, "position", to, time)
	_tween.tween_callback(_on_finish)
	await _tween.finished


func play(tween: Tween, from: Vector2, to: Vector2, hit_type: int, cover_pos: Vector2, random_obs: CellObject):
	var from_pos: Vector2 = from
	var to_pos: Vector2 = to

	if hit_type == 0:
		to_pos = cover_pos
	elif hit_type == 1:
		to_pos = random_obs.position
	elif hit_type == 2:
		to_pos = from_pos + _get_little_wrong_shoot_direction(to_pos - from_pos)

	await create_bullet_and_tween(tween, from_pos, to_pos, Callable())


func _get_little_wrong_shoot_direction(shoot_vector: Vector2) -> Vector2:
	var dir: Vector2 = shoot_vector.normalized()
	var degree = Vector2.RIGHT.angle_to(dir) + PI / 2
	var vec_perpen = Vector2.from_angle(degree) * MISS_MAX_BULLET_OFFSET

	var random_offset = lerp(-vec_perpen, vec_perpen, SHOOT_MISS_POS_LERP.pick_random())
	var with_big_length: Vector2 = (shoot_vector + random_offset).normalized() * MISSED_BULLET_DISTANCE

	return with_big_length
