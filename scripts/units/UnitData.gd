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

var cur_health: float:
	get: return _get_stat_cur_value(UnitStat.StatType.HEALTH)
	set(value): _set_stat_value(UnitStat.StatType.HEALTH, value)

var max_health: float:
	get: return get_stat_value(UnitStat.StatType.HEALTH)

var move_speed: float:
	get: return get_stat_value(UnitStat.StatType.MOVE_SPEED)

var initiative: float:
	get: return get_stat_value(UnitStat.StatType.INITIATIVE)

var range_of_view: float:
	get: return get_stat_value(UnitStat.StatType.RANGE_OF_VIEW)

var is_alive: bool:
	get: return cur_health > 0

var unit_settings: UnitSettings
var unit_stats: Array[UnitStat]
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

	_init_stats(unit_settings)

	is_enemy = ai_settings != null

	init_abilities(unit_settings.abilities)
	init_ai_actions()


func _init_stats(unit_settings: UnitSettings):
	unit_stats.append(UnitStat.new(UnitStat.StatType.HEALTH, unit_settings.max_health))
	unit_stats.append(UnitStat.new(UnitStat.StatType.MOVE_SPEED, unit_settings.walk_speed))
	unit_stats.append(UnitStat.new(UnitStat.StatType.INITIATIVE, unit_settings.initiative))
	unit_stats.append(UnitStat.new(UnitStat.StatType.RANGE_OF_VIEW, unit_settings.range_of_view))


func get_stat_value(stat_type: UnitStat.StatType) -> float:
	var value_sum: float = 0
	for stat in unit_stats:
		if stat.stat_type == stat_type:
			value_sum += stat.stat_value

	if value_sum == 0:
		printerr("stat type {0} not found".format([UnitStat.StatType.keys()[stat_type]]))

	return value_sum


func _get_stat_cur_value(stat_type: UnitStat.StatType) -> float:
	var value_sum: float = 0
	for stat in unit_stats:
		if stat.stat_type == stat_type:
			value_sum += stat.stat_cur_value

	if value_sum == 0:
		printerr("stat type {0} not found".format([UnitStat.StatType.keys()[stat_type]]))

	return value_sum


func _set_stat_value(stat_type: UnitStat.StatType, value: float):
	for stat in unit_stats:
		if stat.stat_type == stat_type:
			stat.stat_cur_value = value


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


