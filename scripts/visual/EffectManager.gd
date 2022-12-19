class_name EffectManager
extends Node2D


@export var bullet_scene: PackedScene

const BULLET_SPEED = 1500


func shoot(from: Unit, to: Unit):
	var new_instance: Node2D = bullet_scene.instantiate()
	add_child(new_instance)

	var from_pos: Vector2 = from.unit_object.position
	var to_pos: Vector2 = to.unit_object.position

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
