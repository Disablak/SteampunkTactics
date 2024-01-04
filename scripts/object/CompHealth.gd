class_name CompHealth
extends Node2D


signal on_health_changed(damage: int, cur_health: int, attacker_id: int)

@export var start_health: int = 0

var is_dead: bool = false
var cur_health: float


func _ready() -> void:
	cur_health = start_health


func set_damage(damage: float, attacker_id: int):
	if cur_health <= 0:
		return

	cur_health -= damage
	on_health_changed.emit(damage, cur_health, attacker_id)

	if cur_health > 0:
		return

	is_dead = true

