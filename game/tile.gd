class_name Tile extends Node2D

signal destroyed

@export var hp: int = 1:
	set(value):
		hp = maxi(0, value)

func apply_damage(damage: int) -> void:
	var was_alive := hp > 0
	hp -= max(0, damage)
	if was_alive and hp <= 0:
		destroyed.emit()
