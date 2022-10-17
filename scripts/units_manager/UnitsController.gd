class_name UnitsController
extends Node2D




#@onready var draw_line3d = get_node("%DrawLine3D")
#@onready var mouse_pointer = get_node("%MousePointer")
#@onready var bullet_effects = get_node("BulletEffects")
#@onready var brain_ai : BrainAI = get_node("%BrainAI") as BrainAI





var shooting_module: ShootingModule




func _init():
	GlobalBus.connect(GlobalBus.on_unit_died_name,Callable(self,"_on_unit_died"))


func _ready() -> void:
	#shooting_module = ShootingModule.new(get_world_3d(), bullet_effects)
	
	



func _process(delta: float) -> void:
	#shooting_module.show_debug(delta)
	pass






func _on_input_system_on_click_world(raycast_result, input_event) -> void:
	if walking.is_unit_moving():
		print("wait unit {0} moving".format([cur_unit_id]))
		return
	
	if raycast_result.collider.name == "Area3D":
		print("click checked obstacle")
		return
	
	if walking.try_move(raycast_result, input_event, cur_unit_action):
		print("unit {0} moving".format([cur_unit_id]))
		return

	if shooting_module.try_shoot(raycast_result, input_event, cur_unit_action):
		print("unit {0} shooting".format([cur_unit_id]))
		return


func _on_input_system_on_mouse_hover(hover_info) -> void:
	if walking.is_unit_moving():
		return
	
	if cur_unit_action == Globals.UnitAction.WALK and hover_info.hover_type == Globals.MouseHoverType.GROUND:
		_draw_future_path(hover_info.pos)
	elif cur_unit_action == Globals.UnitAction.SHOOT and hover_info.hover_type == Globals.MouseHoverType.UNIT:
		shooting_module.show_shoot_hint(true, hover_info.unit_id)
	else:
		line2d.clear_points()
		shooting_module.show_shoot_hint(false)
		TurnManager.show_hint_spend_points(0)


func _on_BtnUnitReload_pressed() -> void:
	shooting_module.reload_weapon()





func _try_to_enemy_continue_turn() -> void:
	if cur_unit_object.is_player_unit:
		return
		
	#brain_ai.decide_best_action_and_execute()





func _change_unit_action(action_type, enable):
	var future_action
	
	if action_type == cur_unit_action or not enable:
		future_action = Globals.UnitAction.NONE;
	else:
		future_action = action_type
	
	GlobalBus.emit_signal(GlobalBus.on_unit_changed_action_name, cur_unit_id, future_action)
	cur_unit_action = future_action


func move_unit_mode(enable: bool) -> void:
	_change_unit_action(Globals.UnitAction.WALK, enable)
	if not enable:
		line2d.clear_points()


func shoot_unit_mode(enable: bool) -> void:
	_change_unit_action(Globals.UnitAction.SHOOT, enable)
	line2d.clear_points()
