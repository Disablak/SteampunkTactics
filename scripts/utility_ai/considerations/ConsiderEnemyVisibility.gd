class_name ConsiderEnemyVisibility
extends Consideration


func calc_score() -> float:
	var cur_unit : Unit = GlobalUnits.get_cur_unit()
	var enemy: Unit = GlobalUnits.units[0]

	var raycaster: Raycaster = GlobalMap.raycaster;
	var is_enemy_visible := raycaster.make_ray_check_no_obstacle(cur_unit.unit_object.position, enemy.unit_object.position)
	
	print("enemy is visible {0}".format([is_enemy_visible]))
	
	return 1.0 if is_enemy_visible else 0.0
