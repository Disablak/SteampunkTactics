extends Sprite2D


@export var cursor: Node2D
@export var trigger_zone: Sprite2D


var _line_width: float


func _on_mini_game_on_changed_value(value: float) -> void:
	cursor.position.x = snappedi(_line_width * value, 1)


func _on_mini_game_on_started(trigger_zone_pos: float, trigger_zone_width: float) -> void:
	_line_width = texture.get_width() * scale.x

	trigger_zone.position.x = _line_width * trigger_zone_pos
	trigger_zone.scale.x = scale.x * trigger_zone_width


func _on_mini_game_on_triggered(success: bool) -> void:
	pass # Replace with function body.
