class_name ShootingModule
extends Node2D


enum HitType {NONE, HIT, HIT_IN_COVER, MISS, HIT_IN_OBS}

var random_number_generator: RandomNumberGenerator = null
var effect_manager: EffectManager
var raycaster: Raycaster
var pathfinding: Pathfinding
var line2d_manager: Line2dManager

var selected_enemy: Unit
var obstacles: Array[CellObject]
var obstacles_sum_debaff: float
var cover: CellObject
var cover_hit_pos: Vector2


func _ready() -> void:
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func set_data(effect_manager: EffectManager, raycaster: Raycaster, pathfinding: Pathfinding, line2d_manager: Line2dManager):
	self.effect_manager = effect_manager
	self.raycaster = raycaster
	self.pathfinding = pathfinding
	self.line2d_manager = line2d_manager


func select_enemy(enemy: Unit):
	selected_enemy = enemy

	var cur_unit: Unit = GlobalUnits.get_cur_unit()

	_detect_obstacles(cur_unit, enemy)
	_show_hit_chance(cur_unit, enemy)

	TurnManager.show_hint_spend_points(cur_unit.unit_data.weapon.use_price)

	var positions = raycaster.make_ray_and_get_positions(cur_unit.unit_object.position, enemy.unit_object.position, true)
	line2d_manager.draw_ray(positions)


func _detect_obstacles(cur_unit: Unit, enemy: Unit):
	var unit_pos := cur_unit.unit_object.position
	var enemy_pos := enemy.unit_object.position

	var intersected_obs = raycaster.make_ray_get_obstacles(unit_pos, enemy_pos)
	for obs in intersected_obs:
		if obs.cell_type == CellObject.CellType.COVER and pathfinding.is_unit_in_cover(enemy_pos, obs):
			self.cover = obs
			cover_hit_pos = raycaster.make_ray_and_get_collision_point(unit_pos, enemy_pos, Raycaster.MASK_OBSTACLE)
			break

	obstacles = Globals.get_cells_of_type(intersected_obs, CellObject.CellType.OBSTACLE)
	_calc_obs_debaff()


func _show_hit_chance(cur_unit: Unit, enemy_unit: Unit):
	var hit_chance: float = _get_hit_chance(cur_unit)
	var cover_debaff: float = cover.shoot_debaf if cover else 0.0
	var obs_debaff: float = obstacles_sum_debaff
	var miss: float = (1.0 - hit_chance) - (cover_debaff + obs_debaff)

	var str_hit_chance: String = "Hit {0}\nHit in cover {1}\nHit in obstacle {2}\nMiss {3}".format([Globals.format_hit_chance(hit_chance), Globals.format_hit_chance(cover_debaff), Globals.format_hit_chance(obs_debaff), Globals.format_hit_chance(miss)])
	GlobalsUi.gui.show_tooltip(true, str_hit_chance, enemy_unit.unit_object.position + Vector2(20, -10))


func deselect_enemy():
	selected_enemy = null
	obstacles = []
	obstacles_sum_debaff = 0.0
	cover = null
	cover_hit_pos = Vector2.ZERO

	GlobalsUi.gui.show_tooltip(false, "", Vector2.ZERO)


func shoot(shooter: Unit):
	if selected_enemy == null:
		GlobalsUi.message("Enemy unit not selected!")
		return

	if not TurnManager.can_spend_time_points(shooter.unit_data.weapon.use_price):
		GlobalsUi.message("Not enough time points!")
		return

	if not shooter.unit_data.is_enough_ammo():
		GlobalsUi.message("Not enough ammo!")
		return

	if shooter == selected_enemy:
		GlobalsUi.message("Shoot same unit!")
		return

	if not raycaster.make_ray_check_no_obstacle(shooter.unit_object.position, selected_enemy.unit_object.position):
		GlobalsUi.message("Obstacle!")
		return

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.SHOOTING, shooter.unit_data.weapon.use_price)
	shooter.unit_data.spend_weapon_ammo()

	var hit_type: HitType = _get_shoot_result(shooter)
	var hitted_obs: CellObject = obstacles.pick_random() if obstacles.size() > 0 else null

	match hit_type:
		HitType.HIT:
			selected_enemy.unit_data.set_damage(shooter.unit_data.weapon.damage, shooter.id)

		HitType.HIT_IN_COVER:
			cover.set_damage()

		HitType.HIT_IN_OBS:
			hitted_obs.set_damage()

	effect_manager.shoot(shooter, selected_enemy, hit_type, cover_hit_pos, hitted_obs)

	if selected_enemy.unit_data.cur_health <= 0:
		return

	_detect_obstacles(shooter, selected_enemy)
	_show_hit_chance(shooter, selected_enemy)


func reload(unit_data: UnitData):
	if not TurnManager.can_spend_time_points(unit_data.weapon.reload_price):
		GlobalsUi.message("Not enough time points!")
		return

	if unit_data.cur_weapon_ammo == unit_data.weapon.ammo:
		GlobalsUi.message("Ammo is full!")
		return

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.RELOADING, unit_data.weapon.reload_price)
	unit_data.reload_weapon()


func _get_shoot_result(shooter: Unit):
	var chance_to_hit: float = _get_hit_chance(shooter)
	var cover_debaff: float = cover.shoot_debaf if cover else 0.0
	var obs_debaff: float = obstacles_sum_debaff

	var rand_hit = randf()
	print("rand_hit {0}".format([Globals.format_hit_chance(rand_hit)]))
	if rand_hit > chance_to_hit:
		return HitType.HIT

	var rand_cover = randf()
	print("rand_cover {0}".format([Globals.format_hit_chance(rand_cover)]))
	if rand_cover < cover_debaff:
		return HitType.HIT_IN_COVER

	var rand_obs = randf()
	print("rand_obs {0}".format([Globals.format_hit_chance(rand_obs)]))
	if rand_obs < obs_debaff:
		return HitType.HIT_IN_OBS

	return HitType.MISS


func _get_hit_chance(shooter: Unit) -> float:
	var weapon_accuracy: float = _get_weapon_accuracy(shooter)
	var cover_debaff: float = cover.shoot_debaf if cover else 0.0
	var chance: float = clamp(weapon_accuracy - (cover_debaff + obstacles_sum_debaff), 0.0, 1.0)

	print("weapon_accuracy {0}, cover debaff {1}, obs debaff {2}, result {3}".format([Globals.format_hit_chance(weapon_accuracy), Globals.format_hit_chance(cover_debaff), Globals.format_hit_chance(obstacles_sum_debaff), Globals.format_hit_chance(chance)]))

	return chance


func get_distance_to_enemy(cur_unit: Unit) -> float:
	if selected_enemy == null:
		printerr("Enemy unit not selected!")
		return 0.0

	return cur_unit.unit_object.position.distance_to(selected_enemy.unit_object.position)


func throw_granade(unit: Unit, cell_pos: Vector2) -> bool:
	if not TurnManager.can_spend_time_points(unit.unit_data.granade.use_price):
		GlobalsUi.message("Not enough time points!")
		return false

	var distance := unit.unit_object.position.distance_to(cell_pos) / Globals.CELL_SIZE
	if distance > unit.unit_data.granade.throw_distance:
		GlobalsUi.message("Distance too long!")
		return false

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.SHOOTING, unit.unit_data.granade.use_price)

	var damaged_cells = pathfinding.get_cells_by_pattern(cell_pos, Globals.CELL_AREA_3x3)

	for cell_info in damaged_cells:
		if cell_info.unit_id != -1:
			var unit_data: UnitData = GlobalUnits.units[cell_info.unit_id].unit_data
			unit_data.set_damage(unit.unit_data.granade.damage, unit.id)

	effect_manager.granade(damaged_cells)

	return true


func _get_weapon_accuracy(shooter: Unit) -> float:
	var distance := get_distance_to_enemy(shooter)
	var weapon_accuracy: float = shooter.unit_data.unit_settings.weapon.accuracy.sample(distance / Globals.CURVE_X_METERS)
	return weapon_accuracy


func _calc_obs_debaff() -> float:
	if obstacles.size() == 0:
		obstacles_sum_debaff = 0.0
		return 0.0

	obstacles_sum_debaff = 0.0
	for obs in obstacles:
		obstacles_sum_debaff += obs.shoot_debaf

	obstacles_sum_debaff = clampf(obstacles_sum_debaff, 0.0, 1.0)
	return obstacles_sum_debaff

