extends Node


var world : MyWorld
var raycaster : Raycaster
var ai_world: AiWorld


func can_show_cur_unit() -> bool:
	if Globals.DEBUG_SHOW_ENEMY_ALWAYS:
		return true

	if not GlobalUnits.cur_unit_is_enemy:
		return true

	if world.units_manager.pathfinding.fog_of_war.is_unit_visible_to_enemy(GlobalUnits.get_cur_unit()):
		return true

	return false
