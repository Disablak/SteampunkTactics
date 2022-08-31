class_name ShootData
extends Reference


var shooter_id: int
var shooter_pos: Vector3

var enemy_id: int
var enemy_pos: Vector3

var shoot_point: Vector3 = Vector3.ZERO
var target_points: PoolVector3Array = []

var distance: float = -1.0
var weapon: WeaponData = null

var visibility: float = -1.0
var hit_chance: float = -1.0
