extends GameObject
class_name UnitObject


@export var unit_name: String = "Unit"
@export var unit_settings_resource: UnitSettingsResource
@export var beehave_tree: BeehaveTree

@onready var main_sprite: Sprite2D = $VisualObject
@onready var noticed_icon: Sprite2D = $VisualObject/NoticedIcon
@onready var health_bar: HealthBar = $VisualObject/HealthBar
@onready var aim_target: Node2D = %AimTarget
@onready var weapon_pointer: Node2D = $WeaponPointer

@onready var nav_obstacle: NavObstacle = $NavObstacle as NavObstacle


var unit_id = -1
var unit_settings: UnitSetting
var main_material: Material
var is_visible := true
var ai_zone_rect: Rect2i
var origin_offset := 0
var main_sprite_def_pos: Vector2
var tween: Tween

var origin_pos: Vector2:
	get: return position

var aim_point: Vector2:
	get: return aim_target.global_position

var shoot_point: Vector2:
	get: return $ShootPoint.global_position

var visual_ordering: int:
	get: return main_sprite.z_index
	set(value): main_sprite.z_index = value

var is_enemy: bool:
	get: return beehave_tree != null

var is_tween_running: bool:
	get: return tween and tween.is_valid() and tween.is_running()


func init_unit(unit_id, unit_data: UnitData) -> void:
	self.unit_id = unit_id

	health_bar.init(unit_id)
	comp_health.unit_data = unit_data

	origin_offset = Globals.get_height_of_obj(main_sprite.texture.region) + main_sprite.offset.y + main_sprite.position.y


func try_to_start_ai():
	if is_enemy:
		beehave_tree.enable()


func try_to_finish_ai():
	if is_enemy:
		beehave_tree.disable()


func _ready() -> void:
	super._ready()

	main_sprite_def_pos = main_sprite.position

	show_noticed_icon(false)


func _exit_tree() -> void:
	nav_obstacle.disable_obstacle()


func mark_selected():
	GlobalUnits.units_manager.effect_manager.select_unit_effect(position)


func set_visibility(is_visible):
	self.is_visible = is_visible
	visible = is_visible


func play_kick_anim(dir: Vector2):
	const KICK_DISTANCE := Globals.CELL_HALF_SIZE
	const KICK_TIME := 0.1
	tween = create_tween()
	tween.tween_property(main_sprite, "position", main_sprite_def_pos + dir * KICK_DISTANCE, KICK_TIME)
	tween.tween_property(main_sprite, "position", main_sprite_def_pos, KICK_TIME)
	await tween.finished


func play_damage_anim(dir: Vector2):
	tween = create_tween()
	tween.tween_property(main_sprite, "position", main_sprite_def_pos - dir * 5, 0.1)
	tween.tween_property(main_sprite, "position", main_sprite_def_pos, 0.1)
	tween.set_trans(Tween.TRANS_BOUNCE)
	await tween.finished


func rotate_unit(dir: Vector2) -> void:
	var angle := dir.angle_to(Vector2.RIGHT)
	weapon_pointer.rotation = -angle
	main_sprite.flip_h = dir.x < 0


func show_noticed_icon(show: bool):
	if false:
		return

	noticed_icon.visible = show


func disable_obstacle():
	nav_obstacle.disable_obstacle()


func enable_obstacle():
	nav_obstacle.enable_obstacle()


func _on_damaged(attacker_id: int):
	var dir: Vector2 = GlobalUtils.get_dir_from_units(unit_id, attacker_id)
	play_damage_anim(dir)


func _on_died():
	GlobalMap.effect_manager.death_effect(origin_pos - Vector2(10, 10), main_sprite.texture.region)
	queue_free()
