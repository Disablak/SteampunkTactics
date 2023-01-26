extends Node2D
class_name UnitObject


@onready var main_sprite := $Sprite2d as Sprite2D
@onready var view_direction := $ViewDirection as Sprite2D


@export var unit_settings: UnitSettings
@export var ai_settings: AiSettings

var unit_id = -1
var main_material: Material
var is_visible := true
var ai_zone_rect: Rect2i

var grid_pos: Vector2i:
	get: return Globals.convert_to_grid_pos(position)


func init_unit(unit_id, unit_data) -> void:
	self.unit_id = unit_id

	view_direction.visible = unit_data.is_enemy


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

	main_sprite.material = main_sprite.material.duplicate()
	main_material = main_sprite.material

	_update_ai_settings()

	mark_selected(false)


func mark_selected(is_selected: bool):
	main_material.set_shader_parameter("line_thickness", 1.0 if is_selected else 0.0)


func set_visibility(is_visible):
	self.is_visible = is_visible
	visible = is_visible


func update_view_direction(angle):
	view_direction.rotation_degrees = angle


func play_kick_anim(dir: Vector2):
	const KICK_DISTANCE := Globals.CELL_HALF_SIZE
	const KICK_TIME := 0.1
	var tween = create_tween()
	tween.tween_property(main_sprite, "position", main_sprite.position + dir * KICK_DISTANCE, KICK_TIME)
	tween.tween_property(main_sprite, "position", Vector2.ZERO, KICK_TIME)


func play_damage_anim():
	var tween = create_tween()
	tween.tween_property(main_sprite, "position", Vector2.RIGHT * 5, 0.1)
	tween.tween_property(main_sprite, "position", Vector2.ZERO, 0.1)
	tween.set_trans(Tween.TRANS_BOUNCE)


func _on_unit_changed_health(unit_id):
	if self.unit_id != unit_id:
		return

	play_damage_anim()


func _on_unit_died(unit_id, unit_id_killer):
	if self.unit_id != unit_id:
		return

	queue_free()
