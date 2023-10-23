class_name NavigationRegionGenerator
extends NavigationRegion2D


@export var obstacle_offset: float = 10
@export var collision_battleground: CollisionPolygon2D
@export var collision_objects: Array[CollisionPolygon2D]


var _new_navigation_polygon: NavigationPolygon = get_navigation_polygon()
var _polygon_obstacles: Array[PolygonObstacle]


class PolygonObstacle extends RefCounted:
	var merged_collision_polygones: Array[CollisionPolygon2D]
	var polygon: PackedVector2Array


func _ready():
	_regenerate_nav_polygon()

	await get_tree().create_timer(2).timeout
	collision_objects.erase(collision_objects.pick_random())
	_regenerate_nav_polygon()
	print("update")


func update_nav_region(battleground: CollisionPolygon2D, objects: Array[CollisionPolygon2D]):
	collision_battleground = battleground
	collision_objects = objects

	_regenerate_nav_polygon()


func _regenerate_nav_polygon():
	_new_navigation_polygon = NavigationPolygon.new()

	var battleground_polygon := _create_polygon_from_collision_polygon(collision_battleground)
	_new_navigation_polygon.add_outline(battleground_polygon)

	_polygon_obstacles = []
	_create_polygon_obstacle_from_collision_polygon()
	_try_to_merge_polygon_obstacles()
	_add_obstacles_to_nav_polygon()

	navigation_polygon = _new_navigation_polygon


func _create_polygon_obstacle_from_collision_polygon():
	for coll_pol in collision_objects:
		var polygon_obstacle := PolygonObstacle.new()
		polygon_obstacle.merged_collision_polygones = [coll_pol]
		polygon_obstacle.polygon = _create_polygon_from_collision_polygon(coll_pol)
		_polygon_obstacles.append(polygon_obstacle)


func _try_to_merge_polygon_obstacles():
	for pol_obs_0 in _polygon_obstacles:
		for pol_obs_1 in _polygon_obstacles:
			if pol_obs_0 == pol_obs_1:
				continue

			if not _is_polygones_intersects(pol_obs_0.polygon, pol_obs_1.polygon):
				continue

			_merge_polygon_obstacles_and_remove_second(pol_obs_0, pol_obs_1)
			_try_to_merge_polygon_obstacles()


func _merge_polygon_obstacles_and_remove_second(pol_obs_0: PolygonObstacle, pol_obs_1: PolygonObstacle):
	var merged_polygones := Geometry2D.merge_polygons(pol_obs_0.polygon, pol_obs_1.polygon)
	pol_obs_0.merged_collision_polygones.append_array(pol_obs_1.merged_collision_polygones)
	pol_obs_0.polygon = merged_polygones[0]
	_polygon_obstacles.erase(pol_obs_1)


func _add_obstacles_to_nav_polygon():
	for pol_obs in _polygon_obstacles:
		_new_navigation_polygon.add_outline(pol_obs.polygon)

	_new_navigation_polygon.make_polygons_from_outlines()


func _is_polygones_intersects(polygon_0: PackedVector2Array, polygon_1: PackedVector2Array) -> bool:
	var merged := Geometry2D.merge_polygons(polygon_0, polygon_1)
	return merged.size() == 1



func _parse_2d_collisionshapes(root_node: Node2D):
	for node in root_node.get_children():
		if not node.visible:
			continue

		if node.get_child_count() > 0:
			_parse_2d_collisionshapes(node)

		if node is CollisionPolygon2D:
			_new_navigation_polygon.add_outline(_create_polygon_from_collision_polygon(node))


func _create_polygon_from_collision_polygon(collision_polygone: CollisionPolygon2D) -> PackedVector2Array:
	var collisionpolygon_transform: Transform2D = collision_polygone.get_global_transform()
	var collisionpolygon: PackedVector2Array = collision_polygone.polygon

	var new_collision_outline: PackedVector2Array = collisionpolygon_transform * collisionpolygon

	var radius: float = 0 if collision_polygone.name == "GroundCollisionPolygon2D" else obstacle_offset
	var collision_outline_with_radius: Array[PackedVector2Array] = Geometry2D.offset_polygon(new_collision_outline, radius)

	return collision_outline_with_radius[0]
