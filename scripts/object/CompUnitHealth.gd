extends CompHealth


var unit_data: UnitData


func set_damage(damage: float, attacker_id: int):
	if unit_data.is_dead:
		return

	unit_data.set_damage(damage, attacker_id)
	on_health_changed.emit(damage, unit_data.cur_health, attacker_id)
