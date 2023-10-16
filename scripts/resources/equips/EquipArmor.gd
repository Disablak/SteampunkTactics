class_name EquipArmor
extends EquipBase


@export var armor: int = 0
@export var dmg_resist: int = 0
@export var move_speed: int = 0

var _cached_stats: Array[UnitStat]


func get_stats() -> Array[UnitStat]:
	if _cached_stats.size() != 0:
		return _cached_stats

	_cached_stats = [ UnitStat.new(UnitStat.StatType.ARMOR, armor),
		UnitStat.new(UnitStat.StatType.DMG_RESIST, dmg_resist),
		UnitStat.new(UnitStat.StatType.MOVE_SPEED, move_speed)
		]

	return _cached_stats

func _to_string() -> String:
	return super._to_string() + "\n\nArmor {0}\nDamage resist {1}\nMove speed {2}".format([armor, dmg_resist, move_speed])
