extends MerchButton

func _purchased() -> void:
	_controller.player_state.reach += 1

func _get_tooltip(_at_position: Vector2) -> String:
	var before := "%dx%d" % [_controller.player_state.reach + 1, _controller.player_state.reach + 1]
	var after := "%dx%d" % [_controller.player_state.reach + 2, _controller.player_state.reach + 2]
	return "Click area: %s → %s" % [before, after]
