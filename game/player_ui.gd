extends Control

@export var points_text: RichTextLabel
@export var autoclickers_container: Control
@export var autoclickers_text: RichTextLabel

func _notification(what: int) -> void:
	match what:
		Controller.NOTIFICATION_POSSESSED: _possessed(Controller.get_instigator(self))

func _possessed(controller: ExpansionPlayerController) -> void:
	_update_points(controller.player_state.points)
	_update_autoclickers(controller.player_state.autoclickers)
	controller.player_state.points_changed.connect(_update_points)
	controller.player_state.autoclickers_changed.connect(_update_autoclickers)

func _update_points(points: float) -> void:
	points_text.text = "$ %s" % NumFormat.format_points(points)

func _update_autoclickers(autoclickers: int) -> void:
	autoclickers_text.text = "Auto clickers: %s" % autoclickers
	autoclickers_container.visible = autoclickers > 0
