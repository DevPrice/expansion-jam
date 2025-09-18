extends MerchButton

func _purchased() -> void:
	_controller.player_state.leadership = true
