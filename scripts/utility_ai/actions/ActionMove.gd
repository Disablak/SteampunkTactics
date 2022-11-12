class_name ActionMove
extends Action




func execute_action():
	var walking_cells : PackedVector2Array = GlobalUnits.units_manager.walking.cached_walking_cells;
	var random_cell := walking_cells[randi_range(0, walking_cells.size() - 1)]
	GlobalUnits.units_manager.try_move_unit_to_cell(random_cell)


func calc_time_points_price() -> int:
	return 100
