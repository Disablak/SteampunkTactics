class_name ShootingModule
extends Node2D


var random_number_generator: RandomNumberGenerator = null


func _ready() -> void:
	random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()


func shoot(shooter: Unit, enemy: Unit, effect_manager: EffectManager, raycaster: Raycaster):
	print("shoot")
	
	if shooter == enemy:
		printerr("shoot same unit")
		return
	
	if not raycaster.make_ray_check_no_obstacle(shooter.unit_object.position, enemy.unit_object.position):
		printerr("obstacle!")
		return
	
	TurnManager.spend_time_points(TurnManager.TypeSpendAction.SHOOTING, shooter.unit_data.weapon.shoot_price)
	shooter.unit_data.spend_weapon_ammo()
	
	var distance := shooter.unit_object.position.distance_to(enemy.unit_object.position)
	var hit_chance := _get_hit_chance(shooter.unit_data.weapon, distance)
	
	if not _is_hitted(hit_chance):
		print("miss")
		return
	
	print("hitted!")
	
	enemy.unit_data.set_damage(shooter.unit_data.weapon.damage, shooter.id)
	effect_manager.shoot(shooter, enemy)


func _get_hit_chance(weapon: WeaponData, distance: float) -> float:
	var weapon_accuracy = clamp(weapon.accuracy.sample(distance / Globals.CURVE_X_METERS), 0.0, 1.0)
	
	print("hit chance {0}".format([weapon_accuracy]))
	
	return weapon_accuracy


func _is_hitted(hit_chance) -> bool:
	var random_value = random_number_generator.randf()
	
	print("chance: {0}, hit random value: {1}".format([hit_chance, random_value]))
	
	return random_value <= hit_chance
