class_name SettingResource
extends Resource


@export var setting_name: String = "None"

var id: int = -1

func _to_string() -> String:
	return "{0}\n\n".format([setting_name])
