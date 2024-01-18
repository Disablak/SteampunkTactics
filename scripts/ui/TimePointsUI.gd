extends Control


@onready var progress: Control = get_node("Progress")
@onready var progress_hint: Control = get_node("ProgressHint")

var width: float


func _ready() -> void:
	GlobalBus.on_changed_time_points.connect(_on_changed_time_points)
	GlobalBus.on_hint_time_points.connect(_on_hint_time_points)

	width = $ProgressBack.size.x
	progress.size.x = _format_value(TurnManager.cur_time_points)
	progress_hint.size.x = _format_value(TurnManager.cur_time_points)


func _on_changed_time_points(cur_value, max_value):
	progress.size.x = _format_value(cur_value)
	progress_hint.size.x = _format_value(cur_value)


func _on_hint_time_points(cur_value, max_value):
	progress_hint.size.x = _format_value(cur_value)


func _format_value(value: int):
	return value / 100.0 * width
