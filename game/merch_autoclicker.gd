extends MerchButton

func _purchased() -> void:
	_controller.player_state.autoclickers += 1

func _get_tooltip(_at_position: Vector2) -> String:
	return "Auto-clickers: %0.0f [img]res://content/textures/arrow.svg[/img] %0.0f" % [_controller.player_state.autoclickers, _controller.player_state.autoclickers + 1]
