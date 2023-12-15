class_name AbilitySettings
extends SettingResource


@export var use_price: int
@export var damage: float



func _to_string() -> String:
	return super._to_string() + "Use Price {1}\nDamage {2}\n".format([setting_name, use_price, damage])
