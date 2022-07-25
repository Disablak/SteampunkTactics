extends Spatial


func _ready() -> void:
	OS.set_window_always_on_top(true)
	
	reset_marker_position()


func _on_Floor_input_event(_camera: Node, event: InputEvent, position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		$ClickMarker.transform.origin = position
		$Player.target = position


func _on_Player_on_player_reach_target() -> void:
	reset_marker_position()


func reset_marker_position():
	$ClickMarker.transform.origin = Vector3( 0, -10, 0 )
