extends Node


signal on_unit_died(unit_id, unit_id_killer)
signal on_unit_change_health(unit_id)
signal on_unit_changed_control(unit_id, instantly)
signal on_unit_updated_weapon(unit_id: int, weapon: WeaponData)
signal on_unit_stat_changed(unit_id: int, unit_stat: UnitStat)
signal on_unit_equip_added(unit_id: int, equip: EquipBase)
signal on_unit_changed_action(unit_id: int, action: UnitData.UnitAction)


signal on_changed_time_points(cur_points: int, max_points: int)
signal on_hint_time_points(cur_points, max_points)

signal on_change_camera_zoom(zoom: float)
signal on_clicked_next_turn()
