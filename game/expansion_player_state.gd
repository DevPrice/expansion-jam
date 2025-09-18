class_name ExpansionPlayerState extends Node

signal points_changed(points: float)
signal total_points_earned_changed(points: float)
signal autoclickers_changed(autoclickers: int)
signal autoclick(numclicks: int)
signal show_stats

@export var bonus_damage: float = 0.0
@export var damage_amp: float = 1.0
@export var tile_bonus: float = 0.0
@export var reach: int = 0

@export var autoclickers: int = 0:
	set(value):
		autoclickers = value
		autoclickers_changed.emit(value)
@export var autoclicker_bonus_damage: int = 0
@export var autoclicker_damage_amp: float = 1.0

@export var points: float = 0.0:
	set(value):
		var diff = value - points
		points = value
		points_changed.emit(points)
		if diff > 0:
			total_points_earned += diff

@export var total_points_earned: float = 0.0:
	set(value):
		total_points_earned = value
		total_points_earned_changed.emit(points)

func _physics_process(_delta: float) -> void:
	if autoclickers <= 0: return
	var ticks_per_frame := Engine.physics_ticks_per_second
	var frame := Engine.get_physics_frames() % ticks_per_frame
	var base_autoclicks := autoclickers / ticks_per_frame
	var remainder := autoclickers % ticks_per_frame
	if frame < remainder:
		autoclick.emit(base_autoclicks + 1)
	else:
		autoclick.emit(base_autoclicks)

func get_click_damage() -> float:
	return (1.0 + bonus_damage) * damage_amp

func get_autoclick_damage() -> float:
	return (1.0 + autoclicker_bonus_damage) * autoclicker_damage_amp

func enable_stat_tracking() -> void:
	show_stats.emit()
