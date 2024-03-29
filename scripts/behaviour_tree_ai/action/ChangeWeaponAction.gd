class_name ChangeWeaponAction
extends ActionLeaf


@export var weapon_type: WeaponData.WeaponType = WeaponData.WeaponType.NONE


func tick(actor: Node, blackboard: Blackboard) -> int:
	var cur_unit: Unit = GlobalUnits.get_unit((actor as UnitObject).unit_id) as Unit
	var weapons_of_type: Array[WeaponData] = UnitUtils.get_weapon_of_type(cur_unit, weapon_type)

	if weapons_of_type.size() == 0:
		return FAILURE

	cur_unit.unit_data.change_weapon(weapons_of_type[0])
	return SUCCESS

