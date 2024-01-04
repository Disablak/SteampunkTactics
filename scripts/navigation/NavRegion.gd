class_name NavRegion
extends NavigationRegion2D


const GROUND_GROUP = "ground"
const NAV_OBSTACLE_GROUP = "nav_obstacle"


func init():
	_create_nav_region_bounds()
	_subscribe_on_nav_obstacle()
	_bake()


func _create_nav_region_bounds():
	var ground_node: Sprite2D = get_tree().get_nodes_in_group(GROUND_GROUP)[0] as Sprite2D
	var ground_pos: Vector2 = ground_node.position
	var ground_size: Vector2 = Vector2(ground_node.scale.x * ground_node.texture.get_width(), ground_node.scale.y * ground_node.texture.get_height())

	var bounding_outline = PackedVector2Array([
		ground_pos,
		ground_pos + Vector2(0, ground_size.y),
		ground_pos + ground_size,
		ground_pos + Vector2(ground_size.x, 0)]
	)

	var new_navigation_mesh = NavigationPolygon.new()
	new_navigation_mesh.add_outline(bounding_outline)
	new_navigation_mesh.agent_radius = 3
	new_navigation_mesh.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_MESH_INSTANCES
	new_navigation_mesh.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_EXPLICIT
	new_navigation_mesh.source_geometry_group_name = NAV_OBSTACLE_GROUP

	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, NavigationMeshSourceGeometryData2D.new());
	navigation_polygon = new_navigation_mesh



func _subscribe_on_nav_obstacle():
	var all_nav_obstacles = get_tree().get_nodes_in_group(NavObstacle.OBSTACLE_GROUP_NAME)
	for nav_obstacle in all_nav_obstacles:
		nav_obstacle.on_obstacle_change.connect(_on_obstacle_change)


func _on_obstacle_change():
	_bake()


func _bake():
	bake_navigation_polygon(false)

