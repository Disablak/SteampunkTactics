class_name ConsiderUnitState
extends Consideration


@export var unit_ai_state: AiSettings.AiState


func calc_score() -> float:
	return 1.0 if GlobalUnits.get_cur_unit().unit_data.ai_settings.ai_state == unit_ai_state else 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderUnitState"
