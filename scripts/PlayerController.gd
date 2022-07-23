extends Spatial


func _ready() -> void:
	reset_marker_position()


func _on_Floor_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		$ClickMarker.transform.origin = position
		$Player.target = position


func _on_Player_on_player_reach_target() -> void:
	reset_marker_position()


func reset_marker_position():
	$ClickMarker.transform.origin = Vector3( 0, -10, 0 )
