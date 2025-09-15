class_name ExpansionPlayerState extends Node

signal points_changed(points: float)
signal autoclick(numclicks: int)

@export var bonus_damage: float = 0.0
@export var damage_amp: float = 1.0
@export var auto_clickers: int = 0

@export var points: float = 0.0:
	set(value):
		points = value
		points_changed.emit(points)

func get_click_damage() -> float:
	return (1.0 + bonus_damage) * damage_amp

func get_autoclick_damage() -> float:
	return 1.0

func _autoclick_timer() -> void:
	autoclick.emit(auto_clickers)
