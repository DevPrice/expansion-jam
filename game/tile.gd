class_name Tile extends Node2D

signal damaged(damage: float)
signal destroyed

@export var hp: float = 1:
	set(value):
		hp = maxf(0, value)

@export var point_value: float = 1

func apply_damage(damage: float) -> void:
	var start_hp := hp
	hp -= max(0, damage)
	var dealt := start_hp - hp
	damaged.emit(dealt)
	if start_hp > 0 and is_zero_approx(hp):
		destroyed.emit()
