extends MerchButton

func _purchased() -> void:
	_controller.player_state.reach += 1

func _get_tooltip(_at_position: Vector2) -> String:
	var before := "%dx%d" % [_controller.player_state.reach, _controller.player_state.reach]
	var after := "%dx%d" % [_controller.player_state.reach + 1, _controller.player_state.reach + 1]
	return "Click area: %s → %s" % [before, after]
