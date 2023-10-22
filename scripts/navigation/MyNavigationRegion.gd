class_name MyNavigationRegion
extends NavigationRegion2D


@export var inner_radius: float = 10
@export var collision_polygone_test_0: CollisionPolygon2D
@export var collision_polygone_test_1: CollisionPolygon2D
@export var collision_polygone_test_2: CollisionPolygon2D

@export var collision_polygone_test_3: CollisionPolygon2D

var _new_navigation_polygon: NavigationPolygon = get_navigation_polygon()


func _ready():
	#parse_2d_collisionshapes(self)
	_new_navigation_polygon.add_outline(create_outline_from_collision_polygon(collision_polygone_test_0))
	#_new_navigation_polygon.add_outline(create_outline_from_collision_polygon(collision_polygone_test_3))
#
	var polygon_1 = create_outline_from_collision_polygon(collision_polygone_test_1)
	var polygon_2 = create_outline_from_collision_polygon(collision_polygone_test_2)
	var merged = Geometry2D.merge_polygons(polygon_1, polygon_2)
	var merged_polygones: PackedVector2Array = merged[0]
	var collision_outline_with_radius: Array[PackedVector2Array] = Geometry2D.offset_polygon(merged_polygones, 10)
	_new_navigation_polygon.add_outline(collision_outline_with_radius[0])

	_new_navigation_polygon.make_polygons_from_outlines()
	navigation_polygon = _new_navigation_polygon
#
#	var radius: float = -10.0
#	var outline: PackedVector2Array = navigation_polygon.get_outline(0)
#	var tab: Array[PackedVector2Array] = Geometry2D.offset_polygon(outline, radius)
#	var polygon = NavigationPolygon.new()
#
#	polygon.add_outline(tab[0])
#	polygon.make_polygons_from_outlines()
#	navigation_polygon = polygon

#	await get_tree().create_timer(2).timeout
#	print("removed")
#	_new_navigation_polygon.remove_outline(1)
#	_new_navigation_polygon.make_polygons_from_outlines()


func parse_2d_collisionshapes(root_node: Node2D):
	for node in root_node.get_children():

		if node.get_child_count() > 0:
			parse_2d_collisionshapes(node)

		if node is CollisionPolygon2D:
			_new_navigation_polygon.add_outline(create_outline_from_collision_polygon(node))


func create_outline_from_collision_polygon(collision_polygone: CollisionPolygon2D) -> PackedVector2Array:
	var collisionpolygon_transform: Transform2D = collision_polygone.get_global_transform()
	var collisionpolygon: PackedVector2Array = collision_polygone.polygon

	var new_collision_outline: PackedVector2Array = collisionpolygon_transform * collisionpolygon

	var radius: float = 0 if collision_polygone.name == "GroundCollisionPolygon2D" else inner_radius
	var collision_outline_with_radius: Array[PackedVector2Array] = Geometry2D.offset_polygon(new_collision_outline, radius)

	return collision_outline_with_radius[0]
