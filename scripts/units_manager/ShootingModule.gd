class_name ShootingModule
extends Node2D


var random_number_generator: RandomNumberGenerator = null
var effect_manager: EffectManager
var raycaster: Raycaster
var pathfinding: Pathfinding

var selected_enemy: Unit


func _ready() -> void:
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func set_data(effect_manager: EffectManager, raycaster: Raycaster, pathfinding: Pathfinding):
	self.effect_manager = effect_manager
	self.raycaster = raycaster
	self.pathfinding = pathfinding


func select_enemy(enemy: Unit):
	selected_enemy = enemy

	var str_hit_chance: String = Globals.format_hit_chance(get_hit_chance(GlobalUnits.get_cur_unit()))
	GlobalsUi.gui.show_tooltip(true, str_hit_chance, enemy.unit_object.position)


func deselect_enemy():
	selected_enemy = null
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

	var hit_chance := get_hit_chance(shooter)
	var is_hitted = _is_hitted(hit_chance)

	if is_hitted:
		selected_enemy.unit_data.set_damage(shooter.unit_data.weapon.damage, shooter.id)

	effect_manager.shoot(shooter, selected_enemy, is_hitted)


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
	var weapon_accuracy = clamp(shooter.unit_data.unit_settings.weapon.accuracy.sample(distance / Globals.CURVE_X_METERS), 0.0, 1.0)

	print("hit chance {0}".format([weapon_accuracy]))

	return weapon_accuracy


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
