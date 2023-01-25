class_name MelleWeaponData
extends AbilityData

var melle_weapon_data: MelleWeaponSettings:
	get: return settings as MelleWeaponSettings


func get_attack_cells() -> Array[Vector2i]:
	match melle_weapon_data.type_attack:
		MelleWeaponSettings.MaleeTypeAttack.FOUR_DIR:
			return Globals.CELL_AREA_FOUR_DIR
		MelleWeaponSettings.MaleeTypeAttack.FOUR_DIR_DIAGONAL:
			return Globals.CELL_AREA_FOUR_DIR_DIAGONAL
		MelleWeaponSettings.MaleeTypeAttack.EIGTH_DIR:
			return Globals.CELL_AREA_3x3_WITHOUR_CENTER

	printerr("Not found cells")
	return []
