extends MerchButton

func _purchased() -> void:
	_controller.player_state.tile_bonus += 5

func _get_tooltip(_at_position: Vector2) -> String:
	return "Destroy bonus: $%0.0f → $%0.0f" % [_controller.player_state.tile_bonus, _controller.player_state.tile_bonus + 5]
