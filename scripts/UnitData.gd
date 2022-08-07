extends Reference

class_name UnitData

var unit_id = -1
var cur_health
var max_health


func _init(health):
	cur_health = health
	max_health = health


func set_unit_id(id):
	self.unit_id = id


func set_damage(value):
	if cur_health <= 0:
		print("unit {0} is already dead".format([unit_id]))
		return
	
	cur_health -= value
	GlobalBus.emit_signal(GlobalBus.on_unit_change_health_name, unit_id, cur_health, max_health)
	
	if cur_health <= 0:
		GlobalBus.emit_signal(GlobalBus.on_unit_died_name, unit_id)
		print_debug("unit_died ", unit_id)



