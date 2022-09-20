class_name ShootingModule
extends RefCounted


var is_debug := false

var world: World3D = null
var bullet_effects: BulletEffects = null
var random_number_generator: RandomNumberGenerator = null
var debug_shoot_pos: Vector3
var debug_shoot_targets: PackedVector3Array = []

var cur_unit_object: UnitObject
var cur_unit_data: UnitData

var cur_shoot_data: ShootData
var prev_shoot_data: ShootData = null


func _init(world,bullet_effects):
	self.world = world
	self.bullet_effects = bullet_effects
	
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func set_cur_unit(unit: Unit):
	cur_unit_object = unit.unit_object
	cur_unit_data = unit.unit_data


func show_debug(delta: float) -> void:
	if not is_debug or debug_shoot_targets.size() == 0:
		return
	
#	for point in debug_shoot_targets:
#		DebugDraw.draw_line_3d(debug_shoot_pos, point, Color.WHITE)


func reload_weapon():
	if not TurnManager.can_spend_time_points(cur_unit_data.weapon.reload_price):
		return
	
	TurnManager.spend_time_points(TurnManager.TypeSpendAction.RELOADING, cur_unit_data.weapon.reload_price)
	cur_unit_data.reload_weapon()
	cur_unit_object.unit_animator.play_anim(Globals.AnimationType.RELOADING)


func create_shoot_data():
	cur_shoot_data = ShootData.new()
	cur_shoot_data.shooter_id = cur_unit_data.unit_id
	cur_shoot_data.shooter_pos = cur_unit_object.global_transform.origin


func update_shoot_data(unit_id: int):
	var enemy_object = GlobalUnits.units[unit_id].unit_object
	
	cur_shoot_data.enemy_id = unit_id
	cur_shoot_data.enemy_pos = enemy_object.global_transform.origin
	cur_shoot_data.weapon = cur_unit_data.weapon
	cur_shoot_data.distance = cur_unit_object.global_transform.origin.distance_to(enemy_object.global_transform.origin)
	cur_shoot_data.shoot_point = cur_unit_object.get_shoot_point()
	cur_shoot_data.target_points = enemy_object.get_hit_points()
	cur_shoot_data = _get_hit_result(cur_shoot_data)


func show_shoot_hint(show, unit_id = -1):
	if not show or cur_unit_data.unit_id == unit_id or not GlobalUnits.units.has(unit_id):
		_emit_show_tooltip(show, Vector3.ZERO, "")
		return
	
	update_shoot_data(unit_id)
	
	var enemy_object = GlobalUnits.units[unit_id].unit_object
	var chance_hit = "chance hit: {0}% \n".format(["%0.0f" % (cur_shoot_data.hit_chance * 100)])
	var visibility = "visibility: {0}% \n".format(["%0.0f" % (cur_shoot_data.visibility * 100)])
	var distance = "distance : {0}m \n".format(["%0.1f" % cur_shoot_data.distance])
	
	_emit_show_tooltip(show, enemy_object.global_transform.origin, visibility + distance + chance_hit)


func _emit_show_tooltip(show, world_pos, text):
	GlobalBus.emit_signal(GlobalBus.on_hovered_unit_in_shooting_mode_name, show, world_pos, text)
	TurnManager.show_hint_spend_points(cur_unit_data.weapon.shoot_price if show else 0)


func try_shoot(raycast_result, input_event: InputEventMouseButton, cur_unit_action) -> bool:
	if cur_unit_action != Globals.UnitAction.SHOOT:
		return false
	
	if not (input_event.pressed and input_event.button_index == 1):
		return false
	
	var unit_object = raycast_result.collider.get_parent() as UnitObject
	if not unit_object:
		return false
	
	return shoot(unit_object)


func shoot(unit_object: UnitObject) -> bool:
	if unit_object == cur_unit_object:
		printerr("Is same unit")
		return false
	
	if not cur_unit_data.is_enough_ammo():
		print("Not enough ammo!")
		return false
	
	if cur_shoot_data.visibility == 0.0:
		print("You don't see the enemy")
		return false
	
	if not TurnManager.can_spend_time_points(cur_unit_data.weapon.shoot_price):
		return false
	
	if not GlobalUnits.units.has(unit_object.unit_id):
		printerr("Enemy not exist id: {0}".format([unit_object.unit_id]))
		return false
	
	TurnManager.spend_time_points(TurnManager.TypeSpendAction.SHOOTING, cur_unit_data.weapon.shoot_price)
	
	cur_unit_data.spend_weapon_ammo()
	cur_unit_object.unit_animator.play_anim(Globals.AnimationType.SHOOTING)
	
	update_shoot_data(unit_object.unit_id)
	var is_hitted: bool = _is_hitted(cur_shoot_data)
	
	var enemy = GlobalUnits.units[unit_object.unit_id]
	bullet_effects.shoot(cur_unit_object, enemy.unit_object, is_hitted)
	
	if is_hitted:
		enemy.unit_object.unit_animator.play_anim(Globals.AnimationType.HIT)
		enemy.unit_data.set_damage(cur_unit_data.weapon.damage, cur_unit_data.unit_id)
	
	return is_hitted


func _get_hit_result(shoot_data: ShootData) -> ShootData:
	if _is_same_shoot_data(shoot_data):
		if is_debug:
			print("is same data!")
		return prev_shoot_data
	
	prev_shoot_data = shoot_data
	
	shoot_data.visibility = _get_enemy_visibility(shoot_data)
	shoot_data.hit_chance = _get_hit_chance(shoot_data)
	
	return shoot_data


func _get_enemy_visibility(shoot_data: ShootData) -> float:
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
		if ray_result.is_empty():
			count_hitted += 1
		elif is_debug:
			print(ray_result)
	
	if is_debug:
		print("hitted {0} / {1}".format([count_hitted, shoot_data.target_points.size()]))
	
	prev_shoot_data.visibility = _get_visible_percent(count_hitted)
	return prev_shoot_data.visibility


func _get_hit_chance(shoot_data: ShootData) -> float:
	if shoot_data.visibility == 0.0:
		print("you cant see an enemy")
		return 0.0
	
	if shoot_data.distance >= Globals.CURVE_X_METERS:
		print("distance is to long {0}".format([shoot_data.distance]))
		return 0.0
	
	var weapon_accuracy = clamp(shoot_data.weapon.accuracy.sample(shoot_data.distance / Globals.CURVE_X_METERS), 0.0, 1.0) 
	var hit_chance = shoot_data.visibility * weapon_accuracy
	
	if is_debug:
		print("visibility {0}, weapon_accuracy {1} hit_chance {2}".format([shoot_data.visibility, weapon_accuracy, hit_chance]))
	
	return hit_chance


func _is_hitted(shoot_data: ShootData) -> bool:
	var random_value = random_number_generator.randf()
	
	if is_debug:
		print("chance: {0}, hit random value: {1}".format([shoot_data.hit_chance, random_value]))
	
	return random_value <= shoot_data.hit_chance


func _make_ray(from, to):
	var space_state = world.direct_space_state
	var ray_query_params := PhysicsRayQueryParameters3D.create(from, to, 5) #[PhysicalBone3D, CollisionShape3D]
	ray_query_params.collide_with_bodies = false
	ray_query_params.collide_with_areas = true
	
	var result = space_state.intersect_ray(ray_query_params)
	return result


func _is_same_shoot_data(shoot_data: ShootData) -> bool:
	if not prev_shoot_data:
		return false
	
	var values_calculated = prev_shoot_data.visibility != -1.0 and prev_shoot_data.hit_chance != -1.0
	var shooter_same = shoot_data.shooter_id == prev_shoot_data.shooter_id and shoot_data.shooter_pos == prev_shoot_data.shooter_pos
	var enemy_same   = shoot_data.enemy_id   == prev_shoot_data.enemy_id   and shoot_data.enemy_pos   == prev_shoot_data.enemy_pos
	
	return values_calculated and shooter_same and enemy_same


func _get_visible_percent(count_hitted) -> float:
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

