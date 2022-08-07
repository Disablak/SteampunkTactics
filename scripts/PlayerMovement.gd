extends KinematicBody


export(NodePath) var animation_tree
onready var player_animator : PlayerAnimator = get_node(animation_tree)
