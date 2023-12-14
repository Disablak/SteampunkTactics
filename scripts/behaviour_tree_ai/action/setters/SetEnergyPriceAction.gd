class_name SetEnergyPriceAction
extends ActionLeaf


enum PriceType {
	NONE,
	MOVE_TO_POS,
	MELEE_ATTACK
}

@export var price_type: PriceType = PriceType.NONE


func tick(actor: Node, blackboard: Blackboard) -> int:
	match price_type:
		PriceType.NONE:
			return FAILURE

		PriceType.MOVE_TO_POS:
			blackboard.set_value(BehaviourAiConst.ENERGY_PRICE, _get_price_move(actor, blackboard))

		PriceType.MELEE_ATTACK:
			blackboard.set_value(BehaviourAiConst.ENERGY_PRICE, _get_price_melle_attack(actor, blackboard))

	return SUCCESS


func _get_price_move(actor: Node, blackboard: Blackboard) -> int:
	var unit_object: UnitObject = (actor as UnitObject)
	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_object.unit_id)
	var unit_object_pos: Vector2 = unit_object.position
	var move_pos: Vector2 = blackboard.get_value("move_pos")
	var move_price: int = GlobalUnits.unit_control.move_controll.get_move_price(unit, unit_object_pos, move_pos)
	print("energy_price ", move_price)

	return move_price


func _get_price_melle_attack(actor: Node, blackboard: Blackboard) -> int:
	var unit: Unit = GlobalUnits.unit_list.get_unit((actor as UnitObject).unit_id)
	var price := GlobalUnits.unit_control.melle_attack_controll.get_price_attack(unit)

	return price
