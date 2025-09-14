class_name ExpansionPlayerState extends Node

signal points_changed(points: float)

@export var points: float = 0:
	set(value):
		points = value
		points_changed.emit(points)
