extends Node


var cur_settings_id := -1
var weapon_settings: Array[AbilitySettings]
var equip_settings: Array[EquipBase]


func _ready() -> void:
	_load_weapons()


func _load_weapons():
	var all_files = list_files_in_directory("res://data/settings/weapon/")

	for path in all_files:
		var ability: AbilitySettings = load(path)
		cur_settings_id += 1
		ability.id = cur_settings_id
		weapon_settings.append(ability)


func _load_equips():
	var all_files = list_files_in_directory("res://data/settings/equips/")

	for path in all_files:
		var ability: EquipBase = load(path)
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
