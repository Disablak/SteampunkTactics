class_name FindNearestEnemy
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var is_iam_enemy := (actor as UnitObject).is_enemy
	var enemy_units: Array[Unit] = GlobalUnits.unit_list.get_team_units(!is_iam_enemy)

	if enemy_units.size() == 0:
		return FAILURE

	if enemy_units.size() == 1:
		_set_nearest_enemy(enemy_units[0], blackboard)
		return SUCCESS

	var nearest_distance: float = 10000
	var nearest_unit: Unit
	for enemy: Unit in enemy_units:
		var distance: float = enemy.unit_object.position.distance_to(actor.position)
		if distance < nearest_distance:
			nearest_unit = enemy
			nearest_distance = distance

	_set_nearest_enemy(nearest_unit, blackboard)
	return SUCCESS


func _set_nearest_enemy(enemy: Unit, blackboard: Blackboard):
	print("nearest enemy ", enemy.unit_data.unit_name)
	blackboard.set_value(BehaviourAiConst.TARGET_ENEMY, enemy)
