class_name ConsiderEnoughTP
extends Consideration


enum PriceType {NONE, SHOOT, KICK, RELOAD, MOVE_RAND, MOVE_TO_ENEMY, MOVE_TO_PATRUL, MOVE_TO_COVER, MOVE_ANY_CELL}

@export var price_type: PriceType = PriceType.NONE


func calc_score() -> float:
	if price_type == PriceType.MOVE_TO_ENEMY:
		if not TurnManager.can_spend_time_points(GlobalUnits.get_cur_unit().unit_data.move_speed):
			return 0

		var price_kick := GlobalUnits.get_cur_unit().unit_data.knife.settings.use_price
		print("price move to enemy {0}".format([ai_world.get_price_move_to_enemy()]))
		var price_move_and_kick = price_kick + ai_world.get_price_move_to_enemy()
		return float(TurnManager.cur_time_points) / price_move_and_kick

	if price_type == PriceType.MOVE_TO_COVER:
		var price_shoot := GlobalUnits.get_cur_unit().unit_data.riffle.settings.use_price;
		var price_move_and_shoot = price_shoot + ai_world.get_price_move_to_cover()
		return float(TurnManager.cur_time_points) / price_move_and_shoot

	return 1.0 if TurnManager.can_spend_time_points(get_price_by_type()) else 0.0


func get_price_by_type() -> int:
	match price_type:
		PriceType.SHOOT:
			return GlobalUnits.get_cur_unit().unit_data.riffle.settings.use_price

		PriceType.KICK:
			return GlobalUnits.get_cur_unit().unit_data.knife.settings.use_price

		PriceType.RELOAD:
			return GlobalUnits.get_cur_unit().unit_data.riffle.settings.reload_price

		PriceType.MOVE_RAND:
			return GlobalMap.ai_world.find_random_cell_and_get_price_walk()

		PriceType.MOVE_TO_PATRUL:
			return GlobalMap.ai_world.get_max_price_move()

		PriceType.MOVE_ANY_CELL:
			return GlobalUnits.get_cur_unit().unit_data.move_speed

		_:
			printerr("Price not installed!")
			return 9999


func _to_string() -> String:
	return super._to_string() + "ConsiderEnoughTP {0}".format([PriceType.keys()[price_type]])
