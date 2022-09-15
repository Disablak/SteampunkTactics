extends Node


var on_unit_died_name = "on_unit_died"
signal on_unit_died(unit_id, unit_id_killer)

var on_unit_change_health_name = "on_unit_change_health"
signal on_unit_change_health(unit_id)

var on_unit_changed_walk_distance_name = "on_unit_changed_walk_distance"
signal on_unit_changed_walk_distance(unit_id)

var on_unit_changed_ammo_name = "on_unit_changed_ammo"
signal on_unit_changed_ammo(unit_id, cur_ammo, max_ammo)

var on_setted_unit_control_name = "on_setted_unit_control"
signal on_setted_unit_control(unit_spatial, instantly)

var on_unit_changed_action_name = "on_unit_changed_action"
signal on_unit_changed_action(unit_id, unit_action_type)

var on_hovered_unit_in_shooting_mode_name = "on_hovered_unit_in_shooting_mode"
signal on_hovered_unit_in_shooting_mode(is_hover, world_pos, text)

var on_changed_time_points_name = "on_changed_time_points"
signal on_changed_time_points(type_spend_action, cur_points, max_points)

var on_hint_time_points_name = "on_hint_time_points"
signal on_hint_time_points(cur_points, max_points)
