class_name ConsiderPathToEnemyExist
extends Consideration


func calc_score() -> float:
	var enemy_id := ai_world.find_path_to_near_enemy()
	return 1.0 if enemy_id != -1 else 0.0
