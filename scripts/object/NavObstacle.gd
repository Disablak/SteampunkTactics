class_name NavObstacle
extends Node


signal on_obstacle_change

const OBSTACLE_GROUP_NAME = "nav_obstacle"



func _exit_tree() -> void:
	disable_obstacle()


func enable_obstacle():
	add_to_group(OBSTACLE_GROUP_NAME)
	on_obstacle_change.emit()


func disable_obstacle():
	remove_from_group(OBSTACLE_GROUP_NAME)
	on_obstacle_change.emit()
