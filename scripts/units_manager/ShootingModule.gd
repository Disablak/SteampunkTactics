class_name ShootingModule
extends Node2D


enum HitType {NONE, HIT, HIT_IN_COVER, MISS}

var random_number_generator: RandomNumberGenerator = null
var effect_manager: EffectManager
var raycaster: Raycaster
var pathfinding: Pathfinding
var line2d_manager: Line2dManager

var selected_enemy: Unit
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
	var unit_pos := cur_unit.unit_object.position
	var enemy_pos := enemy.unit_object.position

	var intersected_covers = raycaster.make_ray_check_covers(unit_pos, enemy_pos)
	for cover in intersected_covers:
		if pathfinding.is_unit_in_cover(enemy_pos, cover):
			self.cover = cover
			cover_hit_pos = raycaster.make_ray_and_get_collision_point(unit_pos, enemy_pos, Raycaster.COVER_MASK)
			break

	var hit_chance: float = get_hit_chance(cur_unit)
	var str_hit_chance: String = Globals.format_hit_chance(hit_chance)
	GlobalsUi.gui.show_tooltip(true, str_hit_chance, enemy_pos)

	TurnManager.show_hint_spend_points(cur_unit.unit_data.weapon.use_price)

	var positions = raycaster.make_ray_and_get_positions(unit_pos, enemy_pos, true)
	line2d_manager.draw_ray(positions)


func deselect_enemy():
	selected_enemy = null
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

	var hit_chance_enemy := get_hit_chance(shooter)
	var chance_miss = 1.0 - hit_chance_enemy
	var hit_chance_cover := chance_miss * cover.shoot_debaf if cover else 0.0
	var random = randf()

	var hit_type: HitType

	if random <= hit_chance_cover:
		hit_type = HitType.HIT_IN_COVER
		cover.set_damage()
	elif random <= chance_miss:
		hit_type = HitType.MISS
	else:
		hit_type = HitType.HIT
		selected_enemy.unit_data.set_damage(shooter.unit_data.weapon.damage, shooter.id)

	effect_manager.shoot(shooter, selected_enemy, hit_type, cover_hit_pos)


func reload(unit_data: UnitData):
	if not TurnManager.can_spend_time_points(unit_data.weapon.reload_price):
		GlobalsUi.message("Not enough time points!")
		return

	if unit_data.cur_weapon_ammo == unit_data.weapon.ammo:
		GlobalsUi.message("Ammo is full!")
		return

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.RELOADING, unit_data.weapon.reload_price)
	unit_data.reload_weapon()


func get_hit_chance(shooter: Unit) -> float:
	var distance := get_distance_to_enemy(shooter)
	var weapon_accuracy: float = shooter.unit_data.unit_settings.weapon.accuracy.sample(distance / Globals.CURVE_X_METERS)
	var cover_debaff: float = cover.shoot_debaf * weapon_accuracy if cover else 0.0

	var chance: float = clamp(weapon_accuracy - cover_debaff, 0.0, 1.0)

	print("weapon_accuracy {0}, debaff {1}, result {2}".format([Globals.format_hit_chance(weapon_accuracy), Globals.format_hit_chance(cover_debaff), Globals.format_hit_chance(chance)]))

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

	var pattern = Globals.CELL_AREA_3x3
	var damaged_cells = pathfinding.get_cells_by_pattern(cell_pos, Globals.CELL_AREA_3x3)

	for cell_info in damaged_cells:
		if cell_info.unit_id != -1:
			var unit_data: UnitData = GlobalUnits.units[cell_info.unit_id].unit_data
			unit_data.set_damage(unit.unit_data.granade.damage, unit.id)

	effect_manager.granade(damaged_cells)

	return true


func _is_hitted(hit_chance) -> bool:
	var random_value = random_number_generator.randf()

	print("chance: {0}, hit random value: {1}".format([hit_chance, random_value]))

	return random_value <= hit_chance
