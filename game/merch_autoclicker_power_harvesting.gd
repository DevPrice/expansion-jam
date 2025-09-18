extends MerchButton

func _purchased() -> void:
	_controller.player_state.autoclicker_power_harvest += 1

func _get_tooltip(_at_position: Vector2) -> String:
	return "Auto-clicker power harvested: %0.0f → %0.0f" % [_controller.player_state.autoclicker_power_harvest, _controller.player_state.autoclicker_power_harvest + 1]
