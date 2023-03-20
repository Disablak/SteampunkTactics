class_name AbilitySettings
extends Resource


@export var ability_name: String
@export var use_price: int
@export var damage: float
@export var can_stealth_attack: bool = false

@export_category("AI preset")
@export var ai_preset: AiPreset
