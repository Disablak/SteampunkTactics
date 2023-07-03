class_name UnitSetupUI
extends Control


@export var button_scene: PackedScene

@onready var container_unit_equip: Control = %VBoxContainerUnitEquip
@onready var container_available_equip: Control = %VBoxContainerAvailableEquip
@onready var button_ready: MyButton = %ButtonReady
@onready var unit_tabs: TabBar = %TabBar


var game_progress: GameProgress
var callback_click_ready: Callable



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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


func move_to_available_equip(btn):
	container_unit_equip.remove_child(btn)
	container_available_equip.add_child(btn)
	btn.click_action = func(): return move_to_unit_equip(btn)


func _on_button_ready_button_down() -> void:
	visible = false
	callback_click_ready.call()
