extends Spatial


onready var pathfinding_system = get_node("Level/PathfindingSystem")
onready var player = get_node("Player")
onready var draw_line3d = get_node("Level/DrawLine3D")

var tween_move = Tween.new()

func _ready() -> void:
	OS.set_window_always_on_top(true)

	reset_marker_position()
	add_child(tween_move)


func _on_Floor_input_event(_camera: Node, event: InputEvent, position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		var points = pathfinding_system.find_path(player.global_transform.origin, position)
		move_via_points(points)


func _on_Player_on_player_reach_target() -> void:
	reset_marker_position()


func reset_marker_position():
	$ClickMarker.transform.origin = Vector3( 0, -10, 0 )


func move_via_points(points: PoolVector3Array):
	draw_line3d.add_points(points)
	
	tween_move.stop_all()
	
	var cur_target_id = 0
	
	for point in points:
		if cur_target_id == points.size() - 1:
			player.player_animator.play_anim(Globals.AnimationType.IDLE)
			print("finish!")
			draw_line3d.clear_points()
			return
		
		player.look_at(points[cur_target_id + 1], Vector3.UP)
		player.rotation.x = 0
		
		player.player_animator.play_anim(Globals.AnimationType.WALKING)
		
		tween_move.interpolate_property(
			player,
			"translation", 
			points[cur_target_id], 
			points[cur_target_id + 1],
			1
#			Tween.TRANS_SINE,
#			Tween.EASE_OUT
		)
		tween_move.start()
		
		cur_target_id += 1
		yield(get_tree().create_timer(1), "timeout") 


