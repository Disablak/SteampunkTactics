class_name EffectManager
extends Node2D


@export var selected_frame: Node2D

@export var bullet_scene: PackedScene
@export var granede_scene: PackedScene
@export var fire_effect_scene: PackedScene
@export var unit_death_effect_scene: PackedScene

const FALLING_SPEED = 300

var _line2d_manager: Line2dManager
var _pathfinding: Pathfinding

var _shoot_effect: ShootEffect
var _grenade_effect: GrenadeEffect
var _selected_unit_effect: SelectedUnitEffect


func inject_data(line2d_manager: Line2dManager, pathfinding: Pathfinding):
	self._line2d_manager = line2d_manager
	self._pathfinding = pathfinding


func init():
	_selected_unit_effect = SelectedUnitEffect.new(selected_frame)
	_shoot_effect = ShootEffect.new(bullet_scene, self)

	var callback_create_tween: Callable = create_tween
	_grenade_effect = GrenadeEffect.new(callback_create_tween, granede_scene, fire_effect_scene, self)


func shoot(from: Unit, to: Unit, hit_type: ShootingModule.HitType, cover_pos: Vector2, random_obs: CellObject):
	await _shoot_effect.play(create_tween(), from, to, hit_type, cover_pos, random_obs)


func granade(cells: Array[CellInfo]):
	_grenade_effect.play(cells, _line2d_manager.line2d_trajectory.points)


func death_effect(pos: Vector2, unit_texture_region):
	var effect = unit_death_effect_scene.instantiate()
	add_child(effect)
	effect.position = pos + Globals.CELL_OFFSET
	effect.play_effect(unit_texture_region)


func falling_effect(unit_object: UnitObject):
	var visual_is_under_bridge: bool = unit_object.position.y < _pathfinding.level.ground_plate.position.y
	unit_object.visual_ordering = -50 if visual_is_under_bridge else 50
	unit_object.show_noticed_icon(false)

	var final_pos: Vector2 = Vector2(unit_object.position.x, 300)
	var duration = unit_object.position.distance_to(final_pos) / FALLING_SPEED
	var tween = create_tween()
	tween.tween_property(unit_object, "position", final_pos, duration)
	tween.set_trans(Tween.TRANS_SINE)

	await tween.finished


func select_unit_effect(pos: Vector2):
	_selected_unit_effect.play_effect(create_tween(), pos)

