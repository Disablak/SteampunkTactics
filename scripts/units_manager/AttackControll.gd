class_name AttackControll
extends Node


@export var line2d_manager: Line2dManager
@export var effect_manager: EffectManager

var attack_confirmed: bool = false


func try_to_attack(from: UnitObject, to: UnitObject):

	if attack_confirmed:
		_shoot_and_kill(from, to)
		deselect_attack()
	else:
		#select enemy
		_draw_ray(from, to)
		attack_confirmed = true


func deselect_attack():
	line2d_manager.clear_ray()
	attack_confirmed = false


func _shoot_and_kill(player: UnitObject, enemy: UnitObject):
	await effect_manager._shoot_effect.create_bullet_and_tween(create_tween(), player.position, enemy.position)
	effect_manager.death_effect(enemy.position - Vector2(10, 10), enemy.main_sprite.texture.region)
	enemy.queue_free()


func _draw_ray(from: UnitObject, to: UnitObject):
	var ray_points: Array[Vector2]
	ray_points.assign([from.position, to.position])
	line2d_manager.draw_ray(ray_points)
