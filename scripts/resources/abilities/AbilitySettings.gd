class_name AbilitySettings
extends SettingResource


@export var ability_name: String
@export var use_price: int
@export var damage: float
@export var can_stealth_attack: bool = false

@export_category("AI preset")
@export var ai_preset: AiPreset


func _to_string() -> String:
	return "{0}\n\nUse Price {1}\nDamage {2}\n".format([ability_name, use_price, damage])
