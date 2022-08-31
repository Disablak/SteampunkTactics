extends Spatial


export var is_debug := false

var random_number_generator: RandomNumberGenerator = null
var prev_shoot_data: ShootData = null
var debug_shoot_pos: Vector3
var debug_shoot_targets: PoolVector3Array = []


func _ready() -> void:
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func _process(delta: float) -> void:
	if not is_debug or debug_shoot_targets.size() == 0:
		return
	
	for point in debug_shoot_targets:
		DebugDraw.draw_line_3d(debug_shoot_pos, point, Color.white)


func get_hit_result(shoot_data: ShootData) -> ShootData:
	if _is_same_shoot_data(shoot_data):
		if is_debug:
			print("is same data!")
		return prev_shoot_data
	
	prev_shoot_data = shoot_data
	
	shoot_data.visibility = get_enemy_visibility(shoot_data)
	shoot_data.hit_chance = get_hit_chance(shoot_data)
	
	return shoot_data


func get_enemy_visibility(shoot_data: ShootData) -> float:
	debug_shoot_pos = shoot_data.shoot_point
	debug_shoot_targets = []
	
	if shoot_data.shoot_point == Vector3.ZERO or shoot_data.target_points.size() == 0:
		printerr("need add shoot_point and target_points to shoot_data")
		return 0.0
	
	var count_hitted = 0
	
	for target_point in shoot_data.target_points:
		var ray_result = _make_ray(shoot_data.shoot_point, target_point)
		var target_pos = ray_result.position if ray_result else target_point
		debug_shoot_targets.push_back(target_pos)
		print("pushed data to {0}".format([shoot_data]))
		if not ray_result:
			count_hitted += 1
		elif is_debug:
			print(ray_result)
	
	if is_debug:
		print("hitted {0} / {1}".format([count_hitted, shoot_data.target_points.size()]))
	
	prev_shoot_data.visibility = float(count_hitted) / shoot_data.target_points.size()
	return prev_shoot_data.visibility


func get_hit_chance(shoot_data: ShootData) -> float:
	if shoot_data.visibility == 0.0:
		print("you cant see an enemy")
		return 0.0
	
	if shoot_data.distance >= Globals.CURVE_X_METERS:
		print("distance is to long {0}".format([shoot_data.distance]))
		return 0.0
	
	var weapon_accuracy = clamp(shoot_data.weapon.accuracy.interpolate(shoot_data.distance / Globals.CURVE_X_METERS), 0.0, 1.0) 
	var hit_chance = shoot_data.visibility * weapon_accuracy
	
	if is_debug:
		print("visibility {0}, weapon_accuracy {1} hit_chance {2}".format([shoot_data.visibility, weapon_accuracy, hit_chance]))
	
	return hit_chance


func is_hitted(shoot_data: ShootData) -> bool:
	var random_value = random_number_generator.randf()
	
	if is_debug:
		print("chance: {0}, hit random value: {1}".format([shoot_data.hit_chance, random_value]))
	
	return random_value <= shoot_data.hit_chance


func _make_ray(from, to):
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [PhysicalBone, CollisionShape], 5, false, true)
	return result


func _is_same_shoot_data(shoot_data: ShootData) -> bool:
	if not prev_shoot_data:
		return false
	
	var values_calculated = prev_shoot_data.visibility != -1.0 and prev_shoot_data.hit_chance != -1.0
	var shooter_same = shoot_data.shooter_id == prev_shoot_data.shooter_id and shoot_data.shooter_pos == prev_shoot_data.shooter_pos
	var enemy_same   = shoot_data.enemy_id   == prev_shoot_data.enemy_id   and shoot_data.enemy_pos   == prev_shoot_data.enemy_pos
	
	return values_calculated and shooter_same and enemy_same

