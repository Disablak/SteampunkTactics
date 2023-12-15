class_name ChangeWeaponAction
extends ActionLeaf


@export var to_ranged: bool = true


func tick(actor: Node, blackboard: Blackboard) -> int:
	var unit: Unit = GlobalUnits.get_unit((actor as UnitObject).unit_id) as Unit
	var all_weapons: Array[WeaponData] = unit.unit_data.all_weapons

	var weapons: Array[WeaponData] = all_weapons.filter(func(x): return (x is RangedWeaponData) if to_ranged else (x is MelleWeaponData))
	if weapons.size() == 0:
		return FAILURE

	unit.unit_data.change_weapon(weapons[0])
	return SUCCESS

