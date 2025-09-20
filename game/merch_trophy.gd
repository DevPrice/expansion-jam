extends MerchButton

func _purchased() -> void:
	_controller.player_state.unlock_trophy()

func _get_tooltip(_at_position: Vector2) -> String:
	return "Victories: 0 [img]res://content/textures/arrow.svg[/img] 1"
