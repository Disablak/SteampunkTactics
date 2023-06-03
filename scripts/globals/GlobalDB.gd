extends Node


var cur_settings_id := -1
var weapon_settings: Array[AbilitySettings]


func _ready() -> void:
	var folder_path = "res://data/settings/weapon/"
	var all_files = list_files_in_directory(folder_path)
	var weapons: Array[AbilitySettings]

	for path in all_files:
		var ability: AbilitySettings = load(path)
		cur_settings_id += 1
		ability.id = cur_settings_id
		weapon_settings.append(ability)



func list_files_in_directory(path):
	var files = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(path + file)

	dir.list_dir_end()

	return files
