class_name ExpansionPlayerState extends Node

signal points_changed(points: int)

@export var points: int = 0:
	set(value):
		points = value
		points_changed.emit(points)
