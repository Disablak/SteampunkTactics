extends KinematicBody

signal on_player_reach_target

export(NodePath) var animation_tree
onready var _player_animator : PlayerAnimator = get_node(animation_tree)

export(float) var speed = 5
export(float) var distance_to_stop = 0.1

var target = null
var velocity := Vector3.ZERO
var gravity := Vector3.ZERO

func _physics_process(delta: float) -> void:
	if target:
		follow_target(delta)
	
	velocity += aplly_gravity(delta)
	velocity = move_and_slide(velocity, Vector3.UP)


func follow_target(delta: float):
	_player_animator.play_anim(Globals.AnimationType.WALKING)

	var direction : Vector3 = (transform.origin - target).normalized()
	look_at(direction, Vector3.UP)
	
	velocity = -global_transform.basis.z * speed * delta
	
	if transform.origin.distance_to(target) < distance_to_stop:
		_player_animator.play_anim(Globals.AnimationType.IDLE)
		target = null
		velocity = Vector3.ZERO
		emit_signal("on_player_reach_target")


func aplly_gravity(delta: float) -> Vector3:
	if is_on_floor():
		gravity = Vector3.ZERO
	else:
		gravity += Vector3( 0.0, -9.8 * delta, 0.0 )
	
	return gravity
