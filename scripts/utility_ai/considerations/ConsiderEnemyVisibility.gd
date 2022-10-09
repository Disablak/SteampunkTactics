class_name ConsiderEnemyVisibility
extends Consideration


func calc_score() -> float:
	var cur_unit : Unit = GlobalUnits.get_cur_unit()
	var enemy: Unit = GlobalUnits.units[0]
	var visibility : float = GlobalUnits.units_controller.shooting_module.get_visibility(enemy, cur_unit)
	
	return visibility
