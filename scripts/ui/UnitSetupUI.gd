class_name UnitSetupUI
extends Control


@export var button_scene: PackedScene

@onready var container_unit_equip: Control = %VBoxContainerUnitEquip
@onready var container_available_equip: Control = %VBoxContainerAvailableEquip
@onready var button_ready: MyButton = %ButtonReady



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ability in GlobalDB.weapon_settings:
		var new_button: MyButton = button_scene.instantiate() as MyButton
		new_button.text = ability.ability_name
		new_button.set_data(ability)
		new_button.click_action = func(): return move_to_unit_equip(new_button)
		container_available_equip.add_child(new_button)


func move_to_unit_equip(btn: MyButton):
	container_available_equip.remove_child(btn)
	container_unit_equip.add_child(btn)
	btn.click_action = func(): return move_to_available_equip(btn)


func move_to_available_equip(btn):
	container_unit_equip.remove_child(btn)
	container_available_equip.add_child(btn)
	btn.click_action = func(): return move_to_unit_equip(btn)


func _on_button_ready_button_down() -> void:
	for btn in container_unit_equip.get_children():
		print(btn._ability_setting_data.id)
