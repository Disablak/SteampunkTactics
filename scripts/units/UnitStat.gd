class_name UnitStat
extends RefCounted


enum StatType {NONE, HEALTH, MOVE_SPEED, INITIATIVE, RANGE_OF_VIEW, BAG_SIZE, DODGE, AIM, ARMOR, DMG_RESIST}

var stat_type: StatType = StatType.NONE
var stat_value: float = -1
var stat_cur_value: float = -1


func _init(stat_type: StatType, stat_value: float) -> void:
	self.stat_type = stat_type
	self.stat_value = stat_value
	stat_cur_value = stat_value
