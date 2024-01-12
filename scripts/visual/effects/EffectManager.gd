class_name EffectManager
extends Node2D


@export var bullet_scene: PackedScene
@export var granede_scene: PackedScene
@export var fire_effect_scene: PackedScene
@export var unit_death_effect_scene: PackedScene

const FALLING_SPEED = 300

var _line2d_manager: Line2dManager

var shoot_effect: ShootEffect
var grenade_effect: GrenadeEffect


func inject_data(line2d_manager: Line2dManager):
	self._line2d_manager = line2d_manager


func _ready() -> void:
	shoot_effect = ShootEffect.new(bullet_scene, self)

	var callback_create_tween: Callable = create_tween
	grenade_effect = GrenadeEffect.new(callback_create_tween, granede_scene, fire_effect_scene, self)


func create_shoot_effect(shoot_data: ShootData, on_finish: Callable) -> ShootEffect:
	var effect: ShootEffect = ShootEffect.new(bullet_scene, self)
	effect.tween_bullet(create_tween(), shoot_data, on_finish)
	return effect


func shoot(from: Unit, to: Unit, cover_pos: Vector2, random_obs: CellObject):
	await shoot_effect.play(create_tween(), from.unit_object.visual_pos, to.unit_object.visual_pos, 0, cover_pos, random_obs)


func granade(cells: Array[CellInfo]):
	grenade_effect.play(cells, _line2d_manager.line2d_trajectory.points)


func death_effect(pos: Vector2, unit_texture_region: Rect2):
	var effect := unit_death_effect_scene.instantiate()
	add_child(effect)
	effect.position = pos + Globals.CELL_OFFSET
	effect.play_effect(unit_texture_region)


func falling_effect(unit_object: UnitObject):
	#var visual_is_under_bridge: bool = unit_object.position.y < _pathfinding.level.ground_plate.position.y
	unit_object.visual_ordering = -50 if true else 50
	unit_object.show_noticed_icon(false)

	var final_pos: Vector2 = Vector2(unit_object.position.x, 300)
	var duration = unit_object.position.distance_to(final_pos) / FALLING_SPEED
	var tween = create_tween()
	tween.tween_property(unit_object, "position", final_pos, duration)
	tween.set_trans(Tween.TRANS_SINE)

	await tween.finished


