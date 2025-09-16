class_name ExpansionPlayerState extends Node

signal points_changed(points: float)
signal autoclickers_changed(autoclickers: int)
signal autoclick(numclicks: int)

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
		var prev_value := points
		points = value
		if not is_equal_approx(prev_value, value):
			points_changed.emit(points)

func get_click_damage() -> float:
	return (1.0 + bonus_damage) * damage_amp

func get_autoclick_damage() -> float:
	return (1.0 + autoclicker_bonus_damage) * autoclicker_damage_amp

func _autoclick_timer() -> void:
	autoclick.emit(autoclickers)
