class_name NavRegion
extends NavigationRegion2D


func _ready() -> void:
	_subscribe_on_nav_obstacle()
	_bake()


func _subscribe_on_nav_obstacle():
	var all_nav_obstacles = get_tree().get_nodes_in_group(NavObstacle.OBSTACLE_GROUP_NAME)
	for nav_obstacle in all_nav_obstacles:
		nav_obstacle.on_obstacle_change.connect(_on_obstacle_change)


func _on_obstacle_change():
	_bake()


func _bake():
	bake_navigation_polygon(false)

