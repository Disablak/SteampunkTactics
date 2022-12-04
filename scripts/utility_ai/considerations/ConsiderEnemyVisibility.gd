class_name ConsiderEnemyVisibility
extends Consideration


func calc_score() -> float:
	var cur_unit : Unit = GlobalUnits.get_cur_unit()
	var visible_enemy: Unit = GlobalMap.world.try_find_any_visible_enemy(cur_unit)

	print("enemy is visible {0}".format([visible_enemy != null]))

	return 1.0 if visible_enemy != null else 0.0
