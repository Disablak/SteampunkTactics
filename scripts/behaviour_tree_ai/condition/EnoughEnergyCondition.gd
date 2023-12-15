class_name EnoughEnergyCondition
extends ConditionLeaf


enum Price {
	NONE,
	MOVE_TO_POS,
	MELEE_ATTACK
}

@export var price: Price = Price.NONE


func tick(actor: Node, blackboard: Blackboard) -> int:
	var energy_price: int = _get_price(actor, blackboard)
	if TurnManager.can_spend_time_points(energy_price):
		return SUCCESS
	else:
		return FAILURE


func _get_price(actor: Node, blackboard: Blackboard) -> int:
	match price:
		Price.MOVE_TO_POS:
			return _get_price_move(actor, blackboard)

		Price.MELEE_ATTACK:
			return _get_price_melle_attack(actor, blackboard)

	push_error("price not implemented for ", price)
	return 100


func _get_price_move(actor: Node, blackboard: Blackboard) -> int:
	var unit: Unit = GlobalUnits.unit_list.get_unit((actor as UnitObject).unit_id)
	var move_pos: Vector2 = blackboard.get_value(BehaviourAiConst.MOVE_POS)
	var move_price: int = GlobalUnits.unit_control.move_controll.get_move_price(unit, unit.origin_pos, move_pos)

	return move_price


func _get_price_melle_attack(actor: Node, blackboard: Blackboard) -> int:
	var unit: Unit = GlobalUnits.unit_list.get_unit((actor as UnitObject).unit_id)
	var price := GlobalUnits.unit_control.melle_attack_controll.get_price_attack(unit)

	return price
