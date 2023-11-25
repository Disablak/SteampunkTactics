extends Node2D

@export var camera: Camera2D
@export var navigation_region: NavigationRegion2D
@export var collision_battleground: CollisionPolygon2D
@export var object_selector: ObjectsSelector
@export var player: Node2D
@export var line2d_manager: Line2dManager

var target_pos: Vector2

