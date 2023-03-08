extends Node2D
class_name UnitObject


@onready var main_sprite := $VisualObject as Sprite2D
@onready var view_direction := $CenterPoint/ViewDirection as Sprite2D

@export var unit_settings: UnitSettings
@export var ai_settings: AiSettings
@export var start_view_dir: int = 0

var unit_id = -1
var main_material: Material
var is_visible := true
var ai_zone_rect: Rect2i
var origin_offset := 0

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

	view_direction.visible = unit_data.is_enemy
	unit_data.update_view_direction(start_view_dir)

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

	GlobalBus.on_unit_died.connect(_on_unit_died)
	GlobalBus.on_unit_change_health.connect(_on_unit_changed_health)
	GlobalBus.on_unit_changed_view_direction.connect(_on_unit_changed_view_direction)

	_update_ai_settings()

	mark_selected(false)


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
	tween.tween_property(main_sprite, "position", main_sprite.position + dir * KICK_DISTANCE, KICK_TIME)
	tween.tween_property(main_sprite, "position", Vector2.ZERO, KICK_TIME)
	await tween.finished


func play_damage_anim():
	var tween = create_tween()
	tween.tween_property(main_sprite, "position", Vector2.RIGHT * 5, 0.1)
	tween.tween_property(main_sprite, "position", Vector2.ZERO, 0.1)
	tween.set_trans(Tween.TRANS_BOUNCE)
	await tween.finished


func play_look_around():
	var tween = create_tween()
	tween.tween_property(view_direction, "rotation_degrees", 360, 1.0)


func rotate_unit_visual(left):
	main_sprite.flip_h = left


func _on_unit_changed_health(unit_id):
	if self.unit_id != unit_id:
		return

	pass
	#play_damage_anim()


func _on_unit_died(unit_id, unit_id_killer):
	if self.unit_id != unit_id:
		return

	queue_free()


func _on_unit_changed_view_direction(unit_id, angle, update_fog):
	if self.unit_id != unit_id:
		return

	view_direction.rotation_degrees = angle
	rotate_unit_visual(angle > 90 and angle < 270)

	if angle == 1000: # TODO fix this!
		play_look_around()

