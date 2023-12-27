class_name IfEnoughAmmo
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var cur_unit: Unit = GlobalUnits.get_unit((actor as UnitObject).unit_id) as Unit
	var all_ranged_weapon = UnitUtils.get_weapon_of_type(cur_unit, WeaponData.WeaponType.RANGE)
	var ranged_weapon: RangedWeaponData = all_ranged_weapon[0] as RangedWeaponData

	if ranged_weapon.is_enough_ammo():
		return SUCCESS
	else:
		return FAILURE

