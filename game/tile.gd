class_name Tile extends Node2D

signal damaged(damage: float)
signal destroyed

@export var hp: float = 1:
	set(value):
		hp = maxf(0, value)

@export var point_value: float = 1

@export var _animation_player: AnimationPlayer

func apply_damage(damage: float) -> void:
	var start_hp := hp
	hp -= max(0, damage)
	var dealt := start_hp - hp
	damaged.emit(dealt)
	if dealt > 0:
		_animation_player.stop()
		_animation_player.play("damage")
		if is_zero_approx(hp):
			$TextureRect.position = Vector2(50, 50)
			destroyed.emit()
