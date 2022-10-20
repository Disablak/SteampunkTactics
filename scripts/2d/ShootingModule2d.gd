class_name ShootingModule
extends Node2D


func shoot(shooter: Unit, enemy: Unit):
	print("shoot")
	
	if shooter == enemy:
		printerr("shoot same unit")
		return
	
	enemy.unit_data.set_damage(shooter.unit_data.weapon.damage, shooter.id)
