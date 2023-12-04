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
var unit_name: String
var is_enemy: bool

var cur_health: float:
	get: return _get_stat_cur_value(UnitStat.StatType.HEALTH)
	set(value): _set_stat_value(UnitStat.StatType.HEALTH, value)

var cur_armor: float:
	get: return _get_stat_cur_value(UnitStat.StatType.ARMOR)
	set(value): _set_stat_value(UnitStat.StatType.ARMOR, value)

var max_armor: float:
	get: return _get_stat_value(UnitStat.StatType.ARMOR)

var max_health: float:
	get: return _get_stat_value(UnitStat.StatType.HEALTH)

var move_speed: float:
	get: return _get_stat_value(UnitStat.StatType.MOVE_SPEED)

var initiative: float:
	get: return _get_stat_value(UnitStat.StatType.INITIATIVE)

var range_of_view: float:
	get: return _get_stat_value(UnitStat.StatType.RANGE_OF_VIEW)

var dmg_resist: float:
	get: return _get_stat_value(UnitStat.StatType.DMG_RESIST)

var is_alive: bool:
	get: return cur_health > 0

var is_dead: bool:
	get: return not is_alive

var _unit_stats: Array[UnitStat]
var _unit_settings: UnitSetting

var all_weapons: Array[WeaponData]
var riffle: RangedWeaponData
var knife: MelleWeaponData
var grenade: ThrowItemData

var _cur_weapon: WeaponData



func set_unit_id(id):
	self.unit_id = id


func _init(unit_settings: UnitSetting):
	_unit_settings = unit_settings

	is_enemy = false#ai_settings != null
	unit_name = unit_settings.unit_name

	_init_stats(unit_settings)
	_init_equips(unit_settings.equips)
	_init_weapons(unit_settings.abilities)


func _init_stats(unit_settings: UnitSetting):
	_unit_stats.append(UnitStat.new(UnitStat.StatType.HEALTH, unit_settings.max_health))
	_unit_stats.append(UnitStat.new(UnitStat.StatType.MOVE_SPEED, unit_settings.walk_speed))
	_unit_stats.append(UnitStat.new(UnitStat.StatType.INITIATIVE, unit_settings.initiative))
	_unit_stats.append(UnitStat.new(UnitStat.StatType.RANGE_OF_VIEW, unit_settings.range_of_view))


func _init_equips(equips: Array[EquipBase]):
	for equip: EquipBase in equips:
		_add_equip(equip)


func _add_equip(equip: EquipBase):
	for stat in equip.get_stats():
		if stat.stat_value == 0:
			continue

		if _unit_stats.has(stat):
			continue

		_unit_stats.append(stat)

	GlobalBus.on_unit_equip_added.emit(unit_id, equip)


func _remove_equip(equip: EquipBase):
	for stat in equip.get_stats():
		if not _unit_stats.has(stat):
			continue

		_unit_stats.erase(stat)


func _get_stat_value(stat_type: UnitStat.StatType) -> float:
	return _get_stat_value_base(stat_type, func(stat: UnitStat): return stat.stat_value)


func _get_stat_cur_value(stat_type: UnitStat.StatType) -> float:
	return _get_stat_value_base(stat_type, func(stat: UnitStat): return stat.stat_cur_value)


func _get_stat_value_base(stat_type: UnitStat.StatType, callback_get_value: Callable):
	var value_sum: float = -1.0
	var is_any_stat_exist: bool = false

	for stat in _unit_stats:
		if stat.stat_type == stat_type:
			is_any_stat_exist = true
			value_sum += callback_get_value.call(stat)

	return value_sum


func _set_stat_value(stat_type: UnitStat.StatType, value: float):
	for stat in _unit_stats:
		if stat.stat_type == stat_type:
			if stat.stat_cur_value != value:
				stat.stat_cur_value = value
				GlobalBus.on_unit_stat_changed.emit(unit_id, stat)


func _get_stat_string(stat_type: UnitStat.StatType) -> String:
	var stat_name: String = UnitStat.StatType.keys()[stat_type].capitalize()
	if stat_type == UnitStat.StatType.HEALTH:
		return "{0}: {1}/{2}".format([stat_name, _get_stat_cur_value(stat_type), _get_stat_value(stat_type)])

	return "{0}: {1}".format([stat_name, _get_stat_value(stat_type)])


func get_unit_info_string() -> String:
	return "{0}\n{1}\n{2}\n{3}".format([
		_get_stat_string(UnitStat.StatType.HEALTH),
		_get_stat_string(UnitStat.StatType.MOVE_SPEED),
		_get_stat_string(UnitStat.StatType.INITIATIVE),
		_get_stat_string(UnitStat.StatType.RANGE_OF_VIEW),
		])



func set_damage(value: float, attacker_unit_id: int):
	if cur_health <= 0:
		print("unit {0} is already dead".format([unit_id]))
		return

	if cur_armor > 0:
		cur_armor -= value

		if cur_armor < 0:
			cur_health -= abs(cur_armor)
	else:
		cur_health -= value

	GlobalBus.on_unit_change_health.emit(unit_id)

	if cur_health <= 0:
		GlobalBus.on_unit_died.emit(unit_id, attacker_unit_id)
		print_debug("unit_died ", unit_id)


func get_move_price(count_cells: int) -> int:
	return count_cells * move_speed


func has_ability(ability: Abilities):
	if ability == Abilities.SHOOT or ability == Abilities.RELOAD:
		return riffle != null

	if ability == Abilities.GRENADE:
		return grenade != null

	if ability == Abilities.MALEE_ATACK:
		return knife != null

	return true


func _init_weapons(abilities: Array[AbilitySettings]):
	for setting in abilities:
		if setting is RangedWeaponSettings:
			riffle = RangedWeaponData.new()
			riffle.settings = setting
			all_weapons.append(riffle)

		if setting is MelleWeaponSettings:
			knife = MelleWeaponData.new()
			knife.settings = setting
			all_weapons.append(knife)

		if setting is ThrowItemSettings:
			grenade = ThrowItemData.new()
			grenade.settings = setting
			all_weapons.append(grenade)

	for data in all_weapons:
		data.init_weapon()


