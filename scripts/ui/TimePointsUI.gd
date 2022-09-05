extends Control


onready var progress_bar = get_node("ProgressBar")


func _ready() -> void:
	GlobalBus.connect(GlobalBus.on_changed_time_points_name, self, "_on_changed_time_points")
	
	progress_bar.value = TurnManager.cur_time_points


func _on_changed_time_points(type, cur_value, max_value):
	progress_bar.value = cur_value
