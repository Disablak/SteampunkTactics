class_name ConsiderEnoughTP
extends Consideration


enum PriceType {NONE, SHOOT, KICK, RELOAD, MOVE}

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

		PriceType.MOVE:
			return GlobalMap.ai_world.find_walk_cell_and_get_price()

		_:
			printerr("Price not installed!")
			return 9999
