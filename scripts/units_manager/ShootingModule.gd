class_name ShootingModule
extends Node2D


var random_number_generator: RandomNumberGenerator = null
var effect_manager: EffectManager
var raycaster: Raycaster

var selected_enemy: Unit


func _ready() -> void:
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func set_data(effect_manager: EffectManager, raycaster: Raycaster):
	self.effect_manager = effect_manager
	self.raycaster = raycaster


func select_enemy(enemy: Unit):
	selected_enemy = enemy

	var str_hit_chance: String = Globals.format_hit_chance(get_hit_chance(GlobalUnits.get_cur_unit()))
	GlobalsUi.gui.show_tooltip(true, str_hit_chance, enemy.unit_object.position)


func deselect_enemy():
	selected_enemy = null
	GlobalsUi.gui.show_tooltip(false, "", Vector2.ZERO)


func shoot(shooter: Unit):
	if selected_enemy == null:
		printerr("Enemy unit not selected!")
		return

	if not TurnManager.can_spend_time_points(shooter.unit_data.weapon.shoot_price):
		printerr("not enough tp")
		return

	if shooter == selected_enemy:
		printerr("shoot same unit")
		return

	if not raycaster.make_ray_check_no_obstacle(shooter.unit_object.position, selected_enemy.unit_object.position):
		printerr("obstacle!")
		return

	TurnManager.spend_time_points(TurnManager.TypeSpendAction.SHOOTING, shooter.unit_data.weapon.shoot_price)
	shooter.unit_data.spend_weapon_ammo()

	var hit_chance := get_hit_chance(shooter)

	if not _is_hitted(hit_chance):
		print("miss")
		return

	print("hitted!")

	selected_enemy.unit_data.set_damage(shooter.unit_data.weapon.damage, shooter.id)
	effect_manager.shoot(shooter, selected_enemy)


func reload(unit_data: UnitData):
	if not TurnManager.can_spend_time_points(unit_data.weapon.reload_price):
		printerr("not enough tp to reload")
		return

	if unit_data.cur_weapon_ammo == unit_data.weapon.ammo:
		printerr("ammo is full")
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


func _is_hitted(hit_chance) -> bool:
	var random_value = random_number_generator.randf()

	print("chance: {0}, hit random value: {1}".format([hit_chance, random_value]))

	return random_value <= hit_chance
