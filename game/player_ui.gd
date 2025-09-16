extends Control

@export var points_text: RichTextLabel
@export var autoclickers_container: Control
@export var autoclickers_text: RichTextLabel

var _displayed_score: float:
	set(value):
		_displayed_score = value
		points_text.text = "$ %s" % NumFormat.format_points(value)

var _points_dirty: bool
var _dirty_points: float

func _notification(what: int) -> void:
	match what:
		Controller.NOTIFICATION_POSSESSED: _possessed(Controller.get_instigator(self))

func _possessed(controller: ExpansionPlayerController) -> void:
	_updated_points_deferred(controller.player_state.points)
	_update_autoclickers(controller.player_state.autoclickers)
	controller.player_state.points_changed.connect(_updated_points_deferred)
	controller.player_state.autoclickers_changed.connect(_update_autoclickers)

func _updated_points_deferred(points: float) -> void:
	_points_dirty = true
	_dirty_points = points
	_update_points.call_deferred()

func _update_points() -> void:
	if not _points_dirty: return
	_points_dirty = false
	var points := _dirty_points
	if abs(points - _displayed_score) > 2 and is_inside_tree():
		var tween_duration := clampf(abs(_log10(points) - _log10(_displayed_score)) * .5, .15, 2.0)
		var tween := get_tree().create_tween()
		tween.tween_property(self, "_displayed_score", points, tween_duration)
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	else:
		_displayed_score = points

func _update_autoclickers(autoclickers: int) -> void:
	autoclickers_text.text = "Auto clickers: %s" % autoclickers
	autoclickers_container.visible = autoclickers > 0

func _log10(x: float) -> float:
	return log(x) / log(10.0)
