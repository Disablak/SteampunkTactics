class_name SetPriceMoveEnergyAction
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var unit_object: UnitObject = (actor as UnitObject)
	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_object.unit_id)
	var unit_object_pos: Vector2 = unit_object.position
	var move_pos: Vector2 = blackboard.get_value("move_pos")
	var move_price: int = GlobalUnits.unit_control.move_controll.get_move_price(unit, unit_object_pos, move_pos)

	blackboard.set_value("energy_price", move_price)
	print("energy_price ", move_price)
	return SUCCESS

