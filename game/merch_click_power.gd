extends MerchButton

func _purchased() -> void:
	_controller.player_state.bonus_damage += 1
