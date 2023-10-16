class_name EquipBase
extends SettingResource


@export var price: int = 0
@export var weight: int = 1


func get_stats() -> Array[UnitStat]:
	return []


func _to_string() -> String:
	return super._to_string() + "Price {0}\nWeight {1}".format([price, weight])
