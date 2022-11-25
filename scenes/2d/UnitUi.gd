extends Control


@onready var label_hp: Label = get_node("LabelHp") as Label
@onready var label_action: Label = get_node("LabelAction") as Label


func set_hp(cur, max):
	label_hp.text = "Health: {0}/{1}".format([cur, max])


func set_action(action):
	label_action.text = "Action: {0}".format([action])
