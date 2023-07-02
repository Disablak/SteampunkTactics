extends Node2D
class_name UnitObject


@onready var main_sprite := $VisualObject as Sprite2D
@onready var noticed_icon := $VisualObject/NoticedIcon as Sprite2D
@onready var health_bar := $VisualObject/HealthBar as HealthBar

@export var unit_name: String = "Unit"
@export var unit_settings_resource: UnitSettings
@export var ai_settings: AiSettings

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

var is_enemy: bool:
	get: return ai_settings != null


func init_unit(unit_id, unit_data: UnitData) -> void:
	self.unit_id = unit_id

	health_bar.init(unit_id)

	origin_offset = Globals.get_height_of_obj(main_sprite.texture.region) + main_sprite.offset.y + main_sprite.position.y


func _update_ai_settings():
	if ai_settings == null:
		return

	var node_zone: Node2D = get_node_or_null(ai_settings.walking_zone_node_path)

	var patrul_nodes: Array[Node2D]
	for path in ai_settings.patrul_zones_paths:
		var node = get_node(path)
		patrul_nodes.append(node)

	ai_settings.init(node_zone, patrul_nodes)


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	GlobalBus.on_unit_change_health.connect(_on_unit_changed_health)

	main_sprite_def_pos = main_sprite.position

	_update_ai_settings()

	mark_selected(false)
	show_noticed_icon(false)


func mark_selected(is_selected: bool):
	#main_material.set_shader_parameter("line_thickness", 1.0 if is_selected else 0.0)
	pass


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


func play_damage_anim():
	var tween = create_tween()
	tween.tween_property(main_sprite, "position", main_sprite_def_pos + Vector2.RIGHT * 5, 0.1)
	tween.tween_property(main_sprite, "position", main_sprite_def_pos, 0.1)
	tween.set_trans(Tween.TRANS_BOUNCE)
	await tween.finished


func rotate_unit_visual(dir: Vector2):
	main_sprite.flip_h = dir.x < 0


func show_noticed_icon(show: bool):
	if not is_enemy:
		return

	noticed_icon.visible = show


func _on_unit_changed_health(unit_id):
	if self.unit_id != unit_id:
		return

	pass
	#play_damage_anim()
