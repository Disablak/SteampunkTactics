class_name AllCovers
extends Node2D


const COVER_POINTS_GROUP: = "cover_points"


var covers: Array[CoverPoints]


func init():
	covers.assign(get_tree().get_nodes_in_group(COVER_POINTS_GROUP))


func deinit():
	covers.clear()


func is_unit_in_any_cover(unit: Unit) -> bool:
	for cover in covers:
		if cover.is_unit_in_cover(unit):
			return true

	return false


func try_to_disable_cover_collision(unit: Unit): # only one cover
	for cover in covers:
		if not weakref(cover).get_ref(): #TODO remove from list deleted cover
			continue

		if cover.is_unit_in_cover(unit):
			cover.disable_cover_collision()
			print("disabled")
			return


func enable_all_covers_collision():
	for cover in covers:
		if weakref(cover).get_ref(): #TODO remove from list deleted cover
			cover.enable_conver_collision()

