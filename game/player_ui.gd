extends Control

@export var points_text: RichTextLabel

func _notification(what: int) -> void:
	match what:
		Controller.NOTIFICATION_POSSESSED: _possessed(Controller.get_instigator(self))

func _possessed(controller: ExpansionPlayerController) -> void:
	_update_points(controller.player_state.points)
	controller.player_state.points_changed.connect(_update_points)

func _update_points(points: float) -> void:
	points_text.text = "$ %s" % NumFormat.format_points(points)
