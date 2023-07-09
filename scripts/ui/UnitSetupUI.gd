class_name UnitSetupUI
extends Control


@export var button_scene: PackedScene

@onready var container_unit_equip: Control = %VBoxContainerUnitEquip
@onready var container_available_equip: Control = %VBoxContainerAvailableEquip
@onready var button_ready: MyButton = %ButtonReady
@onready var unit_tabs: TabBar = %TabBar
@onready var label_unit_info: Label = %LabelUnitInfo


var game_progress: GameProgress
var callback_click_ready: Callable
var dict_id_to_abilities = {} # unit id to array of abilities


func _ready() -> void:
	unit_tabs.tab_changed.connect(_on_change_tab)

	for ability in GlobalDB.weapon_settings:
		var new_button: MyButton = button_scene.instantiate() as MyButton
		new_button.text = ability.ability_name
		new_button.set_data(ability)
		new_button.click_action = func(): return move_to_unit_equip(new_button)
		container_available_equip.add_child(new_button)


func init(game_progress: GameProgress, callback: Callable):
	self.game_progress = game_progress
	self.callback_click_ready = callback

	visible = true

	for unit_setting in game_progress.units_setting:
		unit_tabs.add_tab(unit_setting.unit_name)


func move_to_unit_equip(btn: MyButton):
	container_available_equip.remove_child(btn)
	container_unit_equip.add_child(btn)
	btn.click_action = func(): return move_to_available_equip(btn)

	if dict_id_to_abilities.keys().has(unit_tabs.current_tab):
		dict_id_to_abilities[unit_tabs.current_tab].append(btn.get_data())
	else:
		dict_id_to_abilities[unit_tabs.current_tab] = []
		dict_id_to_abilities[unit_tabs.current_tab].append(btn.get_data())


func move_to_available_equip(btn):
	container_unit_equip.remove_child(btn)
	container_available_equip.add_child(btn)
	btn.click_action = func(): return move_to_unit_equip(btn)

	if dict_id_to_abilities.keys().has(unit_tabs.current_tab):
		dict_id_to_abilities[unit_tabs.current_tab].erase(btn.get_data())


func _on_change_tab(id):
	show_unit_info(game_progress.units_setting[id])


func show_unit_info(unit_setting: UnitSetting):
	label_unit_info.text = "Health {0}\nWalk speed {1}\nInitiative {2}".format([unit_setting.max_health, unit_setting.walk_speed, unit_setting.initiative])


func _on_button_ready_button_down() -> void:
	_apply_settings()

	visible = false
	callback_click_ready.call()


func _apply_settings():
	for id in game_progress.units_setting.size():
		game_progress.units_setting[id].abilities.assign(dict_id_to_abilities[id])

