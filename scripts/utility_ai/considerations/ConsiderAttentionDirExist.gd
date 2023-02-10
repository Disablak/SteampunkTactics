class_name ConsiderAttentionDirExist
extends Consideration


enum AttetntionType {NONE, DIR, POS, DIR_OR_POS, ENEMY}
@export var attention_type: AttetntionType = AttetntionType.NONE


func calc_score() -> float:
	match attention_type:
		AttetntionType.DIR:
			return 1.0 if ai_world.is_attention_dir_exist() else 0.0

		AttetntionType.POS:
			return 1.0 if ai_world.is_attention_pos_exist() else 0.0

		AttetntionType.DIR_OR_POS:
			return 1.0 if ai_world.is_attention_pos_exist() || ai_world.is_attention_dir_exist() else 0.0

		AttetntionType.ENEMY:
			return 1.0 if ai_world.is_attention_pos_enemy_exist() else 0.0

		_:
			printerr("not installed AttentionType")
			return 0.0


func _to_string() -> String:
	return super._to_string() + "ConsiderAttentionDirExist to {0}".format([AttetntionType.keys()[attention_type]])
