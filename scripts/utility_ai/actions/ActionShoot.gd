class_name ActionShoot
extends Action


func execute():
	var player: UnitObject = GlobalUnits.units[0].unit_object
	GlobalUnits.units_controller.shooting_module.shoot(player)
