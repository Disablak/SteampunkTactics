class_name CellCompHealth
extends Node2D


@export var health: int = 0
@export var collision_to_disable_on_broke: CollisionShape2D

var destroyed := false


func set_damage(damage: int = 1):
	if health <= 0:
		return

	health -= damage
	if health > 0:
		return

	destroyed = true

	if collision_to_disable_on_broke:
		collision_to_disable_on_broke.disabled = true

	GlobalBus.on_cell_broke.emit(get_parent())

