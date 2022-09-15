class_name BulletEffects
extends Node3D


const BULLET_SPEED = 150
const MISSED_BULLET_DISTANCE = 100
const SHOOT_MISS_POS_LERP = [0.0, 0.1, 0.2, 0.8, 0.9, 1.0]


@export var bullet_scene: PackedScene

var random: RandomNumberGenerator


func _ready() -> void:
	random = RandomNumberGenerator.new()
	random.randomize()


func shoot(unit_obj_shooter: UnitObject, unit_obj_enemy: UnitObject, is_hitted: bool):
	var new_instance = bullet_scene.instantiate()
	add_child(new_instance)
	
	var point_from: Vector3 = unit_obj_shooter.unit_visual.muzzle_flesh.global_translation
	var point_to: Vector3 = unit_obj_enemy.hit_bullet_point.global_translation
	var shoot_direction = point_to - point_from
	
	var shoot_hit = point_from + _get_little_short_shoot(shoot_direction)
	var shoot_miss = point_from + _get_little_wrong_shoot_direction(shoot_direction)
	var shoot_target_pos: Vector3 = shoot_hit if is_hitted else shoot_miss
	
	new_instance.global_translation = point_from
	new_instance.look_at(shoot_target_pos, Vector3.UP)
	
	var distance = point_from.distance_to(shoot_target_pos)
	var time = distance / BULLET_SPEED
	
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_property(
		new_instance, "global_translation",
		shoot_target_pos, time
	)
	tween.tween_callback(Callable(new_instance,"queue_free"))


func _get_little_short_shoot(shoot_direction: Vector3) -> Vector3:
	var normalized_dir = shoot_direction.normalized()
	var shoot_distance = Vector3.ZERO.distance_to(shoot_direction)
	var less_distance = clamp(shoot_distance - 1.0, 0.0, 100) 
	var short_shoot = normalized_dir * less_distance
	
	return short_shoot


func _get_little_wrong_shoot_direction(shoot_direction: Vector3) -> Vector3:
	var left_offset = shoot_direction.cross(Vector3.UP).normalized() / 3
	var random_offset = lerp(-left_offset, left_offset, SHOOT_MISS_POS_LERP[random.randi() % SHOOT_MISS_POS_LERP.size()])
	var with_big_length: Vector3 = (shoot_direction + random_offset).normalized() * MISSED_BULLET_DISTANCE
	
	return with_big_length
