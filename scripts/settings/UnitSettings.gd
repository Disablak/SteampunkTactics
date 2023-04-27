class_name UnitSettings
extends Resource


@export var unit_name: String = "Unit"
@export var max_health: float = 20.0
@export var walk_speed: int = 10 # price for 1 metr
@export var initiative: int = 10
@export var range_of_view: int = 5

@export var equips: Array[EquipBase]
@export var abilities: Array[AbilitySettings]
@export var additional_ai_actions: Array[Action]
