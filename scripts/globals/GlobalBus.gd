extends Node


signal on_unit_died(unit_id, unit_id_killer)
signal on_unit_change_health(unit_id)
signal on_unit_changed_walk_distance(unit_id)
signal on_unit_changed_ammo(unit_id, cur_ammo, max_ammo)
signal on_unit_changed_control(unit_id, instantly)
signal on_unit_changed_action(unit_id, unit_action_type)
signal on_hovered_unit_in_shooting_mode(is_hover, world_pos, text)
signal on_changed_time_points(type_spend_action, cur_points, max_points)
signal on_hint_time_points(cur_points, max_points)
