class_name AttackControll
extends Node


@export var line2d_manager: Line2dManager
@export var effect_manager: EffectManager

var attack_confirmed: bool = false


func try_to_attack(from: Unit, to: Unit):

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


func _shoot_and_kill(player: Unit, enemy: Unit):
	await effect_manager._shoot_effect.create_bullet_and_tween(create_tween(), player.unit_object.position, enemy.unit_object.position)
	enemy.unit_data.set_damage(10, player.id)

	if not enemy.unit_data.is_alive:
		effect_manager.death_effect(enemy.unit_object.position - Vector2(10, 10), enemy.unit_object.main_sprite.texture.region)
		enemy.unit_object.queue_free()


func _draw_ray(from: Unit, to: Unit):
	var ray_points: Array[Vector2]
	ray_points.assign([from.unit_object.position, to.unit_object.position])
	line2d_manager.draw_ray(ray_points)
