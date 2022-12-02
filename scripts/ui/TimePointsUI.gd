extends Control


@onready var progress_bar = get_node("ProgressBar")
@onready var progress_bar_hint = get_node("ProgressBarHint")


func _ready() -> void:
	GlobalBus.on_changed_time_points.connect(_on_changed_time_points)
	GlobalBus.on_hint_time_points.connect(_on_hint_time_points)

	progress_bar.value = TurnManager.cur_time_points
	progress_bar_hint.value = TurnManager.cur_time_points


func _on_changed_time_points(type, cur_value, max_value):
	progress_bar.value = cur_value


func _on_hint_time_points(cur_value, max_value):
	progress_bar_hint.value = cur_value
