extends HealthBar


var _unit_id: int


func _ready() -> void:
	super._ready()

	GlobalBus.on_unit_stat_changed.connect(_on_unit_stat_changed)


func init(unit_id: int):
	_unit_id = unit_id

	await get_tree().process_frame
	_update_healthbar(unit_id)


func _update_healthbar(unit_id):
	if unit_id != _unit_id:
		return

	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_id)
	update_healthar(unit.unit_data.cur_health, unit.unit_data.max_health, unit.unit_data.cur_armor, unit.unit_data.max_armor)


func _on_unit_stat_changed(unit_id: int, stat: UnitStat):
	_update_healthbar(unit_id)
