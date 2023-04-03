class_name ShootingModule
extends Node2D


enum HitType {NONE, HIT, HIT_IN_COVER, MISS, HIT_IN_OBS}

var random_number_generator: RandomNumberGenerator = null
var effect_manager: EffectManager
var raycaster: Raycaster
var pathfinding: Pathfinding
var line2d_manager: Line2dManager

var prev_unit_ability: UnitData.Abilities
var selected_enemy: Unit
var obstacles: Array[CellObject]
var obstacles_sum_debaff: float
var cover: CellObject
var cover_hit_pos: Vector2
var malee_cells: Array[Vector2i]


func _ready() -> void:
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func set_data(effect_manager: EffectManager, raycaster: Raycaster, pathfinding: Pathfinding, line2d_manager: Line2dManager):
	self.effect_manager = effect_manager
	self.raycaster = raycaster
	self.pathfinding = pathfinding
	self.line2d_manager = line2d_manager


func select_enemy(cur_ability: UnitData.Abilities, cur_unit: Unit, enemy: Unit) -> bool:
	if prev_unit_ability == cur_ability and selected_enemy != null and selected_enemy.id == enemy.id:
		match cur_ability:
			UnitData.Abilities.SHOOT:
				return _shoot(cur_unit)

			UnitData.Abilities.MALEE_ATACK:
				return _kick_unit(cur_unit, enemy)
		return false

	deselect_enemy()
	prev_unit_ability = cur_ability
	selected_enemy = enemy

	_show_selected_enemy_info(cur_ability, cur_unit, enemy)

	var dir_to_enemy: int = rad_to_deg(cur_unit.unit_object.position.angle_to_point(enemy.unit_object.position))
	cur_unit.unit_data.update_view_direction(dir_to_enemy, true)

	return false


func deselect_enemy():
	selected_enemy = null
	obstacles = []
	obstacles_sum_debaff = 0.0
	cover = null
	cover_hit_pos = Vector2.ZERO

	GlobalsUi.gui.battle_ui.selected_unit_info.clear()


func _show_selected_enemy_info(cur_ability: UnitData.Abilities, cur_unit: Unit, enemy: Unit):
	match cur_ability:
		UnitData.Abilities.SHOOT:
			_show_shoot_info(cur_unit, enemy)

		UnitData.Abilities.MALEE_ATACK:
			var str_kick_info = "Damage {0}".format([cur_unit.unit_data.knife.settings.damage])
			GlobalsUi.gui.battle_ui.selected_unit_info.set_text(_get_str_unit_info(enemy) + str_kick_info)

		_:
			GlobalsUi.gui.battle_ui.selected_unit_info.set_text(_get_str_unit_info(enemy))


func _show_shoot_info(cur_unit: Unit, enemy: Unit):
	_detect_obstacles(cur_unit, enemy)
	_show_hit_chance(cur_unit, enemy)

	TurnManager.show_hint_spend_points(cur_unit.unit_data.riffle.settings.use_price)

	var positions = raycaster.make_ray_and_get_positions(cur_unit.unit_object.visual_pos, enemy.unit_object.visual_pos, true)
	line2d_manager.draw_ray(positions)


func _detect_obstacles(cur_unit: Unit, enemy: Unit):
	var unit_pos := cur_unit.unit_object.visual_pos
	var enemy_pos := enemy.unit_object.visual_pos

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
	var cover_debaff: float = cover.comp_obstacle.shoot_debaf if (cover and cover.comp_obstacle) else 0.0
	var obs_debaff: float = obstacles_sum_debaff
	var miss: float = (1.0 - hit_chance) - (cover_debaff + obs_debaff)

	var str_hit_chance: String = "Hit {0}\nHit in cover {1}\nHit in obstacle {2}\nMiss {3}".format([Globals.format_hit_chance(hit_chance), Globals.format_hit_chance(cover_debaff), Globals.format_hit_chance(obs_debaff), Globals.format_hit_chance(miss)])
	GlobalsUi.gui.battle_ui.selected_unit_info.set_text(_get_str_unit_info(enemy_unit) + str_hit_chance)


func _get_str_unit_info(unit: Unit): #todo add in constants
	var str_unit_info = "Health {0}/{1}\n".format([unit.unit_data.cur_health, unit.unit_data.unit_settings.max_health])
	return str_unit_info


func _shoot(shooter: Unit) -> bool:
	if selected_enemy == null:
		GlobalsUi.message("Enemy unit not selected!")
		return false

	if not TurnManager.can_spend_time_points(shooter.unit_data.riffle.settings.use_price):
		GlobalsUi.message("Not enough time points!")
		return false

	if not shooter.unit_data.riffle.is_enough_ammo():
		GlobalsUi.message("Not enough ammo!")
		return false

	if shooter == selected_enemy:
		GlobalsUi.message("Shoot same unit!")
		return false

	if not raycaster.make_ray_check_no_obstacle(shooter.unit_object.visual_pos, selected_enemy.unit_object.visual_pos):
		GlobalsUi.message("Obstacle!")
		return false

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.SHOOTING, shooter.unit_data.riffle.settings.use_price)
	shooter.unit_data.riffle.spend_weapon_ammo()

	var hit_type: HitType = _get_shoot_result(shooter)
	var hitted_obs: CellObject = obstacles.pick_random() if obstacles.size() > 0 else null

	effect_manager.shoot(shooter, selected_enemy, hit_type, cover_hit_pos, hitted_obs)

	match hit_type:
		HitType.HIT:
			_set_unit_damage(selected_enemy, shooter, shooter.unit_data.riffle)

		HitType.HIT_IN_COVER:
			if cover.comp_health:
				cover.comp_health.set_damage()

		HitType.HIT_IN_OBS:
			hitted_obs.comp_health.set_damage()

	if selected_enemy == null or selected_enemy.unit_data.cur_health <= 0:
		return true

	_detect_obstacles(shooter, selected_enemy)
	_show_hit_chance(shooter, selected_enemy)

	return true


func reload(unit_data: UnitData):
	if not TurnManager.can_spend_time_points(unit_data.riffle.settings.reload_price):
		GlobalsUi.message("Not enough time points!")
		return

	if unit_data.riffle.cur_weapon_ammo == unit_data.riffle.settings.max_ammo:
		GlobalsUi.message("Ammo is full!")
		return

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.RELOADING, unit_data.riffle.settings.reload_price)
	unit_data.riffle.reload_weapon()


func _get_shoot_result(shooter: Unit):
	var chance_to_hit: float = _get_hit_chance(shooter)
	var cover_debaff: float = cover.comp_obstacle.shoot_debaf if cover else 0.0
	var obs_debaff: float = obstacles_sum_debaff

	var rand_hit = randf()
	print("rand_hit {0}".format([Globals.format_hit_chance(rand_hit)]))
	if rand_hit < chance_to_hit:
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
	var cover_debaff: float = cover.comp_obstacle.shoot_debaf if (cover and cover.comp_obstacle) else 0.0
	var chance: float = clamp(weapon_accuracy - (cover_debaff + obstacles_sum_debaff), 0.0, 1.0)

	print("weapon_accuracy {0}, cover debaff {1}, obs debaff {2}, result {3}".format([Globals.format_hit_chance(weapon_accuracy), Globals.format_hit_chance(cover_debaff), Globals.format_hit_chance(obstacles_sum_debaff), Globals.format_hit_chance(chance)]))

	return chance


func get_distance_to_enemy(cur_unit: Unit) -> float:
	if selected_enemy == null:
		printerr("Enemy unit not selected!")
		return 0.0

	return cur_unit.unit_object.position.distance_to(selected_enemy.unit_object.position) / Globals.CELL_SIZE


func draw_trejectory_granade(grid_pos: Vector2i):
	var cur_unit: Unit = GlobalUnits.get_cur_unit()

	if not cur_unit:
		line2d_manager.clear_trajectory()
		return

	if not cur_unit.unit_data.has_ability(UnitData.Abilities.GRENADE):
		line2d_manager.clear_trajectory()
		return

	if not cur_unit.unit_data.visibility_data.visible_points.has(grid_pos):
		line2d_manager.clear_trajectory()
		return

	var cell_pos = Globals.convert_to_cell_pos(grid_pos) + Globals.CELL_OFFSET
	var distance := cur_unit.unit_object.position.distance_to(cell_pos) / Globals.CELL_SIZE
	line2d_manager.draw_trajectory(cur_unit.unit_object.visual_pos, cell_pos, distance <= cur_unit.unit_data.grenade.settings.throw_distance)


func throw_granade(unit: Unit, grid_pos: Vector2i) -> bool:
	if not TurnManager.can_spend_time_points(unit.unit_data.grenade.settings.use_price):
		GlobalsUi.message("Not enough time points!")
		return false

	if not unit.unit_data.grenade.is_enough_grenades():
		GlobalsUi.message("Not enough grenades!")
		return false

	var cell_pos = Globals.convert_to_cell_pos(grid_pos)
	var distance := unit.unit_object.position.distance_to(cell_pos) / Globals.CELL_SIZE
	if distance > unit.unit_data.grenade.settings.throw_distance:
		GlobalsUi.message("Distance too long!")
		return false

	unit.unit_data.grenade.spend_grenade()
	TurnManager.spend_time_points(TurnManager.TypeSpendAction.THROW_GRENADE, unit.unit_data.grenade.settings.use_price)

	var cells_by_pattern := pathfinding.get_cells_by_pattern(grid_pos, Globals.CELL_AREA_3x3)
	var damaged_cells: Array[CellInfo]
	for cell_info in cells_by_pattern:
		var center_pos = Globals.convert_to_cell_pos(grid_pos) + Globals.CELL_OFFSET
		if not raycaster.make_ray_check_no_obstacle(center_pos, cell_info.cell_obj.visual_pos):
			continue

		damaged_cells.append(cell_info)

		if cell_info.unit_id == -1:
			continue

		var cell_unit: Unit = GlobalUnits.units[cell_info.unit_id]
		_set_unit_damage(cell_unit, unit, unit.unit_data.grenade)

	effect_manager.granade(damaged_cells)

	return true


func update_malee_cells(unit: Unit) -> Array[Vector2i]:
	GlobalMap.draw_debug.clear_malee_raycast_lines()

	malee_cells.clear()

	var unit_grid_pos = Globals.convert_to_grid_pos(unit.unit_object.position)
	var grid_poses = pathfinding.get_grid_poses_by_pattern(unit_grid_pos, unit.unit_data.knife.get_attack_cells())

	for pos in grid_poses:
		var visual_pos = Globals.convert_to_visual_pos(pos)

		if not raycaster.make_ray_check_no_obstacle(unit.unit_object.visual_pos, visual_pos, raycaster.MASK_WALL):
			continue

		if not raycaster.make_ray_check_no_obstacle(unit.unit_object.visual_pos, visual_pos, raycaster.MASK_OBSTACLE):
			continue

		GlobalMap.draw_debug.draw_malee_raycast([unit.unit_object.visual_pos, visual_pos])
		malee_cells.append(pos)

	return malee_cells


func can_kick_unit(unit: Unit, another_unit: Unit) -> bool:
	for grid_cell in malee_cells:
		if another_unit.unit_object.grid_pos == grid_cell:
			return true

	return false


func _kick_unit(unit: Unit, another_unit: Unit) -> bool:
	if not unit.unit_data.has_ability(UnitData.Abilities.MALEE_ATACK):
		GlobalsUi.message("Enemy not have ability")
		return false

	if not can_kick_unit(unit, another_unit):
		GlobalsUi.message("Enemy unit too far!")
		return false

	if not TurnManager.can_spend_time_points(unit.unit_data.knife.settings.use_price):
		GlobalsUi.message("Not enough time points!")
		return false

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.MELLE_ATTACK, unit.unit_data.knife.settings.use_price)
	_set_unit_damage(another_unit, unit, unit.unit_data.knife)

	var dir = (another_unit.unit_object.position - unit.unit_object.position).normalized()
	_kick_animation(unit, another_unit, dir)

	if selected_enemy != null and selected_enemy.unit_data.cur_health > 0:
		_show_selected_enemy_info(prev_unit_ability, unit, another_unit)

	return true


func _kick_animation(unit: Unit, another_unit: Unit, dir: Vector2):
	await unit.unit_object.play_kick_anim(dir)

	if another_unit.unit_object != null:
		another_unit.unit_object.play_damage_anim()


func show_malee_atack_cells(unit: Unit):
	if not unit.unit_data.has_ability(UnitData.Abilities.MALEE_ATACK):
		return

	pathfinding.draw_damage_hints(malee_cells)


func clear_malee_attack_hints():
	pathfinding.clear_damage_hints()


func _get_weapon_accuracy(shooter: Unit) -> float:
	var distance := get_distance_to_enemy(shooter)
	var weapon_accuracy: float = shooter.unit_data.riffle.settings.accuracy.sample(distance / Globals.CURVE_X_METERS) # todo wtf?
	return weapon_accuracy


func _calc_obs_debaff() -> float:
	if obstacles.size() == 0:
		obstacles_sum_debaff = 0.0
		return 0.0

	obstacles_sum_debaff = 0.0
	for obs in obstacles:
		obstacles_sum_debaff += obs.comp_obstacle.shoot_debaf

	obstacles_sum_debaff = clampf(obstacles_sum_debaff, 0.0, 1.0)
	return obstacles_sum_debaff


func _set_unit_damage(unit: Unit, atacker: Unit, ability_data: AbilityData):
	var damage_multiplier = 1.0
	if ability_data.settings.can_stealth_attack:
		if not unit.unit_data.visibility_data.is_enemy_was_noticed(atacker):
			damage_multiplier = 2.0
			GlobalsUi.gui.show_flying_tooltip("stealth", atacker.unit_object.position)

	unit.unit_data.set_damage(ability_data.settings.damage * damage_multiplier, atacker.id)
