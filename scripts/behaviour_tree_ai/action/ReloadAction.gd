class_name ReloadAction
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var cur_unit: Unit = GlobalUnits.get_unit((actor as UnitObject).unit_id) as Unit
	var ranged_weapon: RangedWeaponData = cur_unit.unit_data.cur_weapon as RangedWeaponData
	ranged_weapon.reload_weapon()

	return SUCCESS

