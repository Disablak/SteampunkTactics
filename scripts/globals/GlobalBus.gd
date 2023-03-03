extends Node


signal on_unit_died(unit_id, unit_id_killer)
signal on_unit_change_health(unit_id)
signal on_unit_moved_to_another_cell(unit_id: int, cell_pos: Vector2i)
signal on_unit_changed_control(unit_id, instantly)
signal on_unit_changed_action(unit_id, unit_action_type)
signal on_unit_updated_weapon(unit_id: int, ability: AbilityData)
signal on_unit_changed_view_direction(unit_id: int, view_direction: int, update_fog: bool)

signal on_cell_broke(cell: CellObject)

signal on_changed_time_points(type_spend_action, cur_points, max_points)
signal on_hint_time_points(cur_points, max_points)

signal on_finished_turn()

signal on_change_camera_zoom(zoom: float)
signal on_clicked_ability(ability: UnitData.Abilities)
signal on_clicked_next_turn()

signal on_clicked_cell(cell_info: CellInfo)
signal on_hovered_cell(cell_info: CellInfo)
