extends RefCounted
class_name UnitData

enum Abilities {
	NONE,
	WALK,
	MALEE_ATACK,
	SHOOT,
	RELOAD,
	GRENADE,
	PUSH,
}

var unit_id := -1
var is_enemy: bool
var cur_health: float
var is_alive: bool:
	get: return cur_health > 0

var unit_settings: UnitSettings
var ai_settings: AiSettings
var ai_actions: Array[Action]
var visibility_data: VisibilityData = VisibilityData.new()

var all_abilities: Array[AbilityData]
var riffle: RangedWeaponData
var knife: MelleWeaponData
var grenade: ThrowItemData


func _init(unit_settings: UnitSettings, ai_settings: AiSettings):
	self.unit_settings = unit_settings
	self.ai_settings = ai_settings

	is_enemy = ai_settings != null
	cur_health = unit_settings.max_health

	init_abilities(unit_settings.abilities)
	init_ai_actions()


func set_unit_id(id):
	self.unit_id = id

	if ai_settings != null:
		ai_settings.unit_id = unit_id


func set_damage(value: float, attacker_unit_id: int):
	if cur_health <= 0:
		print("unit {0} is already dead".format([unit_id]))
		return

	cur_health -= value
	GlobalBus.on_unit_change_health.emit(unit_id)

	if ai_settings != null:
		ai_settings.change_state_to_active()

	if cur_health <= 0:
		GlobalBus.on_unit_died.emit(unit_id, attacker_unit_id)
		print_debug("unit_died ", unit_id)


func get_move_price(count_cells: int) -> int:
	return count_cells * unit_settings.walk_speed


func has_ability(ability: Abilities):
	if ability == Abilities.SHOOT or ability == Abilities.RELOAD:
		return riffle != null

	if ability == Abilities.GRENADE:
		return grenade != null

	if ability == Abilities.MALEE_ATACK:
		return knife != null

	return true


func init_ai_actions():
	if not is_enemy:
		return

	for ability in all_abilities:
		if ability.settings.ai_preset != null:
			ai_actions.append_array(ability.settings.ai_preset.ai_actions)

	if unit_settings.additional_ai_actions != null:
		ai_actions.append_array(unit_settings.additional_ai_actions)


func init_abilities(abilities: Array[AbilitySettings]):
	for setting in abilities:
		if setting is RangedWeaponSettings:
			riffle = RangedWeaponData.new()
			riffle.settings = setting
			all_abilities.append(riffle)

		if setting is MelleWeaponSettings:
			knife = MelleWeaponData.new()
			knife.settings = setting
			all_abilities.append(knife)

		if setting is ThrowItemSettings:
			grenade = ThrowItemData.new()
			grenade.settings = setting
			all_abilities.append(grenade)

	for data in all_abilities:
		data.init_weapon()


