extends HealthBar


@export var comp_health: CompHealth


func _ready() -> void:
	super._ready()

	comp_health.on_health_changed.connect(_on_health_changed)

	update_healthar(comp_health.cur_health, comp_health.start_health, 0, 0)


func _on_health_changed(damage: int, cur_health: int, attacker_id: int):
	update_healthar(cur_health, comp_health.start_health, 0, 0)
