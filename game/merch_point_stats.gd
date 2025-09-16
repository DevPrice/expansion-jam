extends MerchButton

func _purchased() -> void:
	_controller.player_state.enable_stat_tracking()
