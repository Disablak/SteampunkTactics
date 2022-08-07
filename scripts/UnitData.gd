extends Reference

class_name UnitData

signal on_unit_died(unit_id)

var unit_id = -1
var cur_health
var max_health


func _init(health):
	cur_health = health
	max_health = health


func set_unit_id(id):
	self.unit_id = id


func set_damage(value):
	cur_health -= value
	print("damage dealt")
	GlobalBus.emit_signal(GlobalBus.on_unit_change_health_name, unit_id, cur_health, max_health)
