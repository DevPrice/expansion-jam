extends MerchButton

func _purchased() -> void:
	_controller.player_state.tile_bonus += 5
