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
@export var max_health: float = 20.0
@export var walk_speed: int = 10 # price for 1 metr
@export var initiative: int = 10
@export var range_of_view: int = 5

@export var weapons: Array[WeaponBaseData]


var riffle: WeaponData:
	get: return _get_weapon_of_type(WeaponData)

var grenade: GranadeData:
	get: return _get_weapon_of_type(GranadeData)

var knife: MaleeData:
	get: return _get_weapon_of_type(MaleeData)


func _get_weapon_of_type(weapon_type) -> WeaponBaseData:
	for weapon in weapons:
		if weapon is weapon_type:
			return weapon

	return null


func init_weapons():
	for weapon in weapons:
		weapon.init_weapon()


func has_ability(ability: Abilities):
	if ability == Abilities.SHOOT or ability == Abilities.RELOAD:
		return riffle != null

	if ability == Abilities.GRENADE:
		return grenade != null

	if ability == Abilities.MALEE_ATACK:
		return knife != null

	return true
