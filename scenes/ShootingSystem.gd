extends Spatial


export var is_debug := false

var cur_shoot_point
var cur_target_points: PoolVector3Array

var random_number_generator: RandomNumberGenerator = null


func _ready() -> void:
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func _process(delta: float) -> void:
	if not is_debug or cur_target_points == null or cur_target_points.size() == 0:
		return
	
	for point in cur_target_points:
		DebugDraw.draw_line_3d(cur_shoot_point, point, Color.white)


func get_enemy_visibility(shoot_point: Vector3, target_points: PoolVector3Array) -> float:
	self.cur_shoot_point = shoot_point
	cur_target_points = PoolVector3Array()
	
	var count_hitted = 0
	
	for point in target_points:
		var ray_result = _make_ray(shoot_point, point)
		var target_pos = ray_result.position if ray_result else point
		cur_target_points.push_back(target_pos)
		if not ray_result:
			count_hitted += 1
		elif is_debug:
			print(ray_result)
	
	if is_debug:
		print("hitted {0} / {1}".format([count_hitted, target_points.size()]))
	
	return float(count_hitted) / target_points.size()


func is_hitted(visibility: float, distance: float, weapon: WeaponData) -> bool:
	if visibility == 0.0:
		print("you cant see an enemy")
		return false
	
	if distance >= Globals.CURVE_X_METERS:
		print("distance is to long {0}".format([distance]))
		return false
	
	var weapon_accuracy = clamp(weapon.accuracy.interpolate(distance / Globals.CURVE_X_METERS), 0.0, 1.0) 
	var hit_chance = visibility * weapon_accuracy
	var random_value = random_number_generator.randf()
	
	if is_debug:
		print("visibility {0}, weapon_accuracy {1} hit_chance {2}, random_value {3}".format([visibility, weapon_accuracy, hit_chance, random_value]))
	
	return random_value <= hit_chance


func _make_ray(from, to):
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [PhysicalBone, CollisionShape], 5, false, true)
	return result

