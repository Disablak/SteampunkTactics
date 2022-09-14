class_name ActionReload
extends Action


func execute():
	GlobalUnits.units_controller.shooting_module.reload_weapon()
