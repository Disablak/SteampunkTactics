class_name UnitSettings
extends Resource


enum Abilities {
	NONE,
	WALK,
	MALEE_ATACK,
	SHOOT,
	RELOAD,
	GRENADE,
}


@export var unit_name: String = "Unit"
@export var is_enemy: bool = false
@export var max_health: float = 20.0
@export var walk_speed: int = 10 # price for 1 metr
@export var initiative: int = 10
@export var range_of_view: int = 5

@export var abilities: Array[Abilities] = [Abilities.WALK]

@export_category("References")
@export var weapon: WeaponData
@export var granade: GranadeData
