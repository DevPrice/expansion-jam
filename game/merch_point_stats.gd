extends MerchButton

func _purchased() -> void:
	_controller.player_state.show_stats.emit()
