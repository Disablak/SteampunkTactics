extends Node


var on_unit_died_name = "on_unit_died"
signal on_unit_died(unit_id)

var on_unit_change_health_name = "on_unit_change_health"
signal on_unit_change_health(unit_id, cur_health, max_health)

var on_unit_changed_walk_distance = "on_unit_changed_walk_distance"
signal on_unit_changed_walk_distance(unit_id, cur_walk, max_walk)
