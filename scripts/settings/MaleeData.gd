class_name MaleeData
extends WeaponBaseData


enum MaleeTypeAttack {FOUR_DIR, FOUR_DIR_DIAGONAL, EIGTH_DIR}

@export var type_attack: MaleeTypeAttack = MaleeTypeAttack.EIGTH_DIR


func get_attack_cells() -> Array[Vector2i]:
	match type_attack:
		MaleeTypeAttack.FOUR_DIR:
			return Globals.CELL_AREA_FOUR_DIR
		MaleeTypeAttack.FOUR_DIR_DIAGONAL:
			return Globals.CELL_AREA_FOUR_DIR_DIAGONAL
		MaleeTypeAttack.EIGTH_DIR:
			return Globals.CELL_AREA_3x3_WITHOUR_CENTER

	printerr("Not found cells")
	return []
