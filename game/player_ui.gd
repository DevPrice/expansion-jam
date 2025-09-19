extends Control

@export var points_container: Control
@export var points_text: RichTextLabel
@export var autoclickers_container: Control
@export var autoclickers_text: RichTextLabel
@export var stat_tracker_text: RichTextLabel
@export var stat_tracker_control: Control
@export var options_container: Control

var _displayed_score: float:
	set(value):
		_displayed_score = value
		points_text.text = "$ %s" % NumFormat.format_points(floorf(value))

var _points_dirty: bool
var _dirty_points: float

var _allow_points_shrink: bool

var _point_tracker := PointTracker.new()

func _notification(what: int) -> void:
	match what:
		Controller.NOTIFICATION_POSSESSED: _possessed(Controller.get_instigator(self))

func _process(_delta: float) -> void:
	if _allow_points_shrink:
		points_container.size.x = 0.0
		points_container.custom_minimum_size.x = 0.0
	else:
		points_container.custom_minimum_size.x = points_container.size.x

func _possessed(controller: ExpansionPlayerController) -> void:
	_updated_points_deferred(controller.player_state.points)
	_update_autoclickers(controller.player_state.autoclickers)
	controller.player_state.points_changed.connect(_updated_points_deferred)
	controller.player_state.show_stats.connect(stat_tracker_control.show, CONNECT_ONE_SHOT)
	controller.player_state.autoclickers_changed.connect(_update_autoclickers)
	_point_tracker.stats_changed.connect(_update_point_stats)

func _updated_points_deferred(points: float) -> void:
	_points_dirty = true
	_dirty_points = points
	_update_points.call_deferred()

func _update_points() -> void:
	if not _points_dirty: return
	_points_dirty = false
	var points := _dirty_points
	var diff := points - _displayed_score
	_allow_points_shrink = diff < 0
	if absf(diff) > 2 and is_inside_tree():
		var tween_duration := clampf(abs(_log10(points) - _log10(_displayed_score)) * .5, .15, 2.0)
		var tween := get_tree().create_tween()
		tween.tween_property(self, "_displayed_score", points, tween_duration)
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	else:
		_displayed_score = points

func _update_autoclickers(autoclickers: int) -> void:
	autoclickers_text.text = "Auto-clickers: %s" % NumFormat.format_points(autoclickers)
	autoclickers_container.visible = autoclickers > 0

func _update_point_stats(avg_points: float) -> void:
	stat_tracker_text.text = "$ %s / s" % NumFormat.format_points(avg_points)

func _log10(x: float) -> float:
	return log(x) / log(10.0)

func _update_stats() -> void:
	var controller: ExpansionPlayerController = Controller.get_instigator(self)
	_point_tracker.add_sample(controller.player_state.total_points_earned)

func _options_button_toggled(toggled_on: bool) -> void:
	options_container.visible = toggled_on

class PointTracker:

	signal stats_changed(avg_points: float)

	var buffer_size: int = 10
	var _buffer: Array[Vector2]

	func add_sample(points: float) -> void:
		_buffer.push_back(Vector2(Time.get_ticks_msec(), points))
		if _buffer.size() > buffer_size:
			_buffer.pop_front()
		var avg_points := get_points_per_second()
		stats_changed.emit(avg_points)

	func get_points_per_second() -> float:
		var size := _buffer.size()
		if size == 0: return 0.0
		if size == 1: return _buffer[0].y
		var difference := _buffer[size - 1] - _buffer[0]
		var seconds := difference.x / 1000.0
		return difference.y / seconds
