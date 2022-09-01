class_name ShootingModule
extends Reference


var is_debug := true

var world: World = null
var random_number_generator: RandomNumberGenerator = null
var debug_shoot_pos: Vector3
var debug_shoot_targets: PoolVector3Array = []

var cur_unit_object: UnitObject
var cur_unit_data: UnitData

var cur_shoot_data: ShootData
var prev_shoot_data: ShootData = null


func _init(world) -> void:
	self.world = world
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func set_cur_unit(unit: Unit):
	cur_unit_object = unit.unit_object
	cur_unit_data = unit.unit_data


func show_debug(delta: float) -> void:
	if not is_debug or debug_shoot_targets.size() == 0:
		return
	
	for point in debug_shoot_targets:
		DebugDraw.draw_line_3d(debug_shoot_pos, point, Color.white)


func update_shoot_data():
	cur_shoot_data = ShootData.new()
	cur_shoot_data.shooter_id = cur_unit_data.unit_id
	cur_shoot_data.shooter_pos = cur_unit_object.global_transform.origin


func show_shoot_hint(show, unit_id = -1):
	if not show or cur_unit_data.unit_id == unit_id or not GlobalUnits.units.has(unit_id):
		_emit_show_tooltip(show, Vector3.ZERO, "")
		return
	
	var enemy_object = GlobalUnits.units[unit_id].unit_object
	
	cur_shoot_data.enemy_id = unit_id
	cur_shoot_data.enemy_pos = enemy_object.global_transform.origin
	cur_shoot_data.weapon = cur_unit_data.weapon
	cur_shoot_data.distance = cur_unit_object.global_transform.origin.distance_to(enemy_object.global_transform.origin)
	cur_shoot_data.shoot_point = cur_unit_object.get_shoot_point()
	cur_shoot_data.target_points = enemy_object.get_hit_points()
	
	var shoot_result: ShootData = get_hit_result(cur_shoot_data)
	var chance_hit = "chance hit: {0}% \n".format(["%0.0f" % (shoot_result.hit_chance * 100)])
	var visibility = "visibility: {0}% \n".format(["%0.0f" % (shoot_result.visibility * 100)])
	var distance = "distance : {0}m \n".format(["%0.1f" % shoot_result.distance])
	
	_emit_show_tooltip(show, enemy_object.global_transform.origin, visibility + distance + chance_hit)


func _emit_show_tooltip(show, world_pos, text):
	GlobalBus.emit_signal(GlobalBus.on_hovered_unit_in_shooting_mode_name, show, world_pos, text)


func try_shoot(raycast_result, input_event: InputEventMouseButton, cur_unit_action):
	if cur_unit_action != Globals.UnitAction.SHOOT:
		return false
	
	if not (input_event.pressed and input_event.button_index == 1):
		return false
	
	var unit_object = raycast_result.collider.get_parent() as UnitObject
	if not unit_object:
		return false
	
	if unit_object == cur_unit_object:
		printerr("unit clicked on yourself")
		return false
	
	cur_unit_object.unit_animator.play_anim(Globals.AnimationType.SHOOTING)
	
	var enemy = GlobalUnits.units[unit_object.unit_id]
	var is_hitted: bool = is_hitted(cur_shoot_data) # yea im sure that here we have all data thats I need
	
	if is_hitted:
		enemy.unit_object.unit_animator.play_anim(Globals.AnimationType.HIT)
		enemy.unit_data.set_damage(cur_unit_data.weapon.damage, cur_unit_data.unit_id)
	
	return is_hitted


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
	
	prev_shoot_data.visibility = _get_visible_percent(count_hitted)
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
	var space_state = world.direct_space_state
	var result = space_state.intersect_ray(from, to, [PhysicalBone, CollisionShape], 5, false, true)
	return result


func _is_same_shoot_data(shoot_data: ShootData) -> bool:
	if not prev_shoot_data:
		return false
	
	var values_calculated = prev_shoot_data.visibility != -1.0 and prev_shoot_data.hit_chance != -1.0
	var shooter_same = shoot_data.shooter_id == prev_shoot_data.shooter_id and shoot_data.shooter_pos == prev_shoot_data.shooter_pos
	var enemy_same   = shoot_data.enemy_id   == prev_shoot_data.enemy_id   and shoot_data.enemy_pos   == prev_shoot_data.enemy_pos
	
	return values_calculated and shooter_same and enemy_same


func _get_visible_percent(var count_hitted) -> float:
	match(count_hitted):
		0:
			return 0.0
		
		1, 2, 3:
			return 0.2
		
		4, 5, 6:
			return 0.45
		
		7, 8, 9:
			return 0.65
		
		10, 11, 12:
			return 1.0
		
		_:
			printerr("out of range!")
			return 0.0

