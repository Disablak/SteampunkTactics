class_name ActionMove
extends Action


var best_cover = null


func pre_action():
	best_cover = GlobalMap.world.get_best_cover()
	super.pre_action()


func execute_action():
	var cur_unit_data : UnitData = GlobalUnits.get_cur_unit().unit_data
	cur_unit_data.enemy_data_ai.cur_cover_data = best_cover
	GlobalUnits.units_controller.walking_system.move_unit(best_cover.pos)


func calc_time_points_price() -> int:
	var move_to_cover_price : int = GlobalUnits.units_controller.walking_system.get_move_price_to_pos(best_cover.pos)
	print("move to cover price {0}".format([move_to_cover_price]))
	return move_to_cover_price
