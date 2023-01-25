class_name ConsiderEnoughTP
extends Consideration


enum PriceType {NONE, SHOOT, KICK, RELOAD, MOVE_RAND, MOVE_TO_ENEMY, MOVE_TO_PATRUL, MOVE_TO_COVER}

@export var price_type: PriceType = PriceType.NONE


func calc_score() -> float:
	return 1.0 if TurnManager.can_spend_time_points(get_price_by_type()) else 0.0


func get_price_by_type() -> int:
	match price_type:
		PriceType.SHOOT:
			return GlobalUnits.get_cur_unit().unit_data.unit_settings.riffle.use_price

		PriceType.KICK:
			return GlobalUnits.get_cur_unit().unit_data.unit_settings.knife.use_price

		PriceType.RELOAD:
			return GlobalUnits.get_cur_unit().unit_data.unit_settings.riffle.reload_price

		PriceType.MOVE_RAND:
			return GlobalMap.ai_world.find_random_cell_and_get_price_walk()

		PriceType.MOVE_TO_ENEMY, PriceType.MOVE_TO_PATRUL, PriceType.MOVE_TO_COVER:
			return GlobalMap.ai_world.get_price_move()

		_:
			printerr("Price not installed!")
			return 9999


func _to_string() -> String:
	return super._to_string() + "ConsiderEnoughTP {0}".format([PriceType.keys()[price_type]])
