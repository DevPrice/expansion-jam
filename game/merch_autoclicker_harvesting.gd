extends MerchButton

func _purchased() -> void:
	_controller.player_state.autoclicker_harvest += 1
