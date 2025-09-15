extends PanelContainer

@onready var _controller: ExpansionPlayerController = Controller.get_instigator(self)

func _on_auto_clicker_purchase() -> void:
	_controller.player_state.auto_clickers += 1
