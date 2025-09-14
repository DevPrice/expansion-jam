class_name Tile extends Node2D

@export var hp: int = 1:
	set(value):
		hp = maxi(0, value)
