extends Node


var on_unit_change_health_name = "on_unit_change_health"
signal on_unit_change_health(unit_id, cur_health, max_health)

var on_unit_died_name = "on_unit_died"
signal on_unit_died(unit_id)
