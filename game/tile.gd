class_name Tile extends Node2D

signal destroyed

@export var hp: float = 1:
	set(value):
		hp = maxf(0, value)

@export var point_value: float = 1

func apply_damage(damage: float) -> void:
	var was_alive := hp > 0
	hp -= max(0, damage)
	if was_alive and is_zero_approx(hp):
		destroyed.emit()
