class_name Action
extends Resource


@export var considerations: Array[Consideration] = []

var ai_world: AiWorld:
	get: return GlobalMap.ai_world

var score: float = 0.0


func execute_action():
	pass


func print_debug():
	Globals.print_ai("{0} total score {1}".format([to_string(), score]) , true, "purple")
