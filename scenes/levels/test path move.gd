extends CharacterBody2D


@onready var agent: NavigationAgent2D = $NavigationAgent2D


func _physics_process(delta: float) -> void:
	agent.target_position = get_global_mouse_position()

	var dir: Vector2 = (agent.get_next_path_position() - global_position).normalized()
	velocity = dir * 100 #velocity.lerp(dir * 50, 7 * delta)
	move_and_slide()

#
#func _ready() -> void:
#	agent.velocity_computed.connect(_on_nav_velocity_computed)
#
#	# create a new "obstacle" and place it on the default navigation map.
#	var new_obstacle_rid: RID = NavigationServer2D.obstacle_create()
#	var default_2d_map_rid: RID = get_world_2d().get_navigation_map()
#
#	NavigationServer2D.obstacle_set_map(new_obstacle_rid, default_2d_map_rid)
#	NavigationServer2D.obstacle_set_position(new_obstacle_rid, global_position)
#
#	# Use obstacle dynamic by increasing radius above zero.
#	NavigationServer2D.obstacle_set_radius(new_obstacle_rid, 5.0)
#
#	# Use obstacle static by adding a square that pushes agents out.
#	var outline = PackedVector2Array([Vector2(356, 117), Vector2(482, 103), Vector2(436, 214)])
#	NavigationServer2D.obstacle_set_vertices(new_obstacle_rid, outline)
#
#	# 	Enable the obstacle.
#	NavigationServer2D.obstacle_set_avoidance_enabled(new_obstacle_rid, true)
#
#
#
#func _physics_process(delta: float) -> void:
#	agent.target_position = get_global_mouse_position()
#
#	var origin = global_transform.origin
#	var target = agent.get_next_path_position()
#	var velocity = (target - origin).normalized()
#	agent.set_velocity(velocity * 300)
#
#
#func _on_nav_velocity_computed(safe_velocity: Vector2) -> void:
#	velocity = safe_velocity
#	move_and_slide()
