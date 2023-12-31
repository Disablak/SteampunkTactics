class_name GameObject
extends Node2D


@onready var comp_health: CompHealth = $CompHealth
@onready var interactable_stat_body: InteractableStaticBody = $InteractableStaticBody as InteractableStaticBody


func _ready() -> void:
	if comp_health:
		comp_health.on_health_changed.connect(_on_health_changed)


func _on_health_changed(damage: int, cur_health: int, attacker_id: int):
	if cur_health > 0:
		_on_damaged(attacker_id)
	else:
		_on_died()


func _on_damaged(attacker_id: int):
	pass


func _on_died():
	queue_free()


func get_this_exclude_rid() -> Array[RID]:
	if interactable_stat_body:
		return [interactable_stat_body.get_rid()]

	return []
