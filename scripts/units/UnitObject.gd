extends Node2D
class_name UnitObject


@onready var main_sprite: Sprite2D = $VisualObject
@onready var noticed_icon: Sprite2D = $VisualObject/NoticedIcon
@onready var health_bar: HealthBar = $VisualObject/HealthBar

@export var unit_name: String = "Unit"
@export var unit_settings_resource: UnitSettingsResource

@onready var nav_obstacle: NavObstacle = $NavObstacle as NavObstacle

var unit_id = -1
var unit_settings: UnitSetting
var main_material: Material
var is_visible := true
var ai_zone_rect: Rect2i
var origin_offset := 0
var main_sprite_def_pos: Vector2

var grid_pos: Vector2i:
	get: return Globals.convert_to_grid_pos(position)

var visual_pos: Vector2:
	get: return position + Globals.CELL_OFFSET

var origin_pos: Vector2:
	get: return position + Vector2(8, origin_offset)

var visual_ordering: int:
	get: return main_sprite.z_index
	set(value): main_sprite.z_index = value


func init_unit(unit_id, unit_data: UnitData) -> void:
	self.unit_id = unit_id

	health_bar.init(unit_id)

	origin_offset = Globals.get_height_of_obj(main_sprite.texture.region) + main_sprite.offset.y + main_sprite.position.y



func _ready() -> void:
	if Engine.is_editor_hint():
		return

	GlobalBus.on_unit_change_health.connect(_on_unit_changed_health)

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
	var tween = create_tween()
	tween.tween_property(main_sprite, "position", main_sprite_def_pos + dir * KICK_DISTANCE, KICK_TIME)
	tween.tween_property(main_sprite, "position", main_sprite_def_pos, KICK_TIME)
	await tween.finished


func play_damage_anim(dir: Vector2):
	var tween = create_tween()
	tween.tween_property(main_sprite, "position", main_sprite_def_pos - dir * 5, 0.1)
	tween.tween_property(main_sprite, "position", main_sprite_def_pos, 0.1)
	tween.set_trans(Tween.TRANS_BOUNCE)
	await tween.finished


func rotate_unit_visual(dir: Vector2):
	main_sprite.flip_h = dir.x < 0


func show_noticed_icon(show: bool):
	if false:
		return

	noticed_icon.visible = show


func disable_obstacle():
	nav_obstacle.disable_obstacle()


func enable_obstacle():
	nav_obstacle.enable_obstacle()


func _on_unit_changed_health(unit_id: int, unit_id_dealer: int):
	if self.unit_id != unit_id:
		return

	var dir: Vector2 = GlobalUtils.get_dir_from_units(unit_id, unit_id_dealer)
	play_damage_anim(dir)
