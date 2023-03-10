extends Node


var world : MyWorld
var raycaster : Raycaster
var ai_world: AiWorld
var draw_debug: DrawDebug


func can_show_cur_unit() -> bool:
	return can_show_unit(GlobalUnits.cur_unit_id)


func can_show_unit(unit_id):
	if Globals.DEBUG_SHOW_ENEMY_ALWAYS:
		return true

	var cur_unit = GlobalUnits.units[unit_id] if GlobalUnits.units.has(unit_id) else null
	if not cur_unit:
		return false

	if not cur_unit.unit_data.is_enemy:
		return true

	if world.units_manager.pathfinding.fog_of_war.is_unit_visible_to_enemy(cur_unit):
		return true

	return false
