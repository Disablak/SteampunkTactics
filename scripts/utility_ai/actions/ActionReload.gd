class_name ActionReload
extends Action


func execute_action():
	GlobalMap.ai_world.reload()
	Globals.print_ai("Reload")

