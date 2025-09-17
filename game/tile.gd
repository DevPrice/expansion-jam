class_name Tile extends Node2D

signal damaged(damage: float)
signal destroyed

@export var hp: float = 1:
	set(value):
		hp = maxf(0, value)
		_max_hp = maxf(_max_hp, value)
		propagate_call("set_instance_shader_parameter", ["damage", 1.0 - hp / _max_hp])

@export var point_value: float = 1

@export var _animation_player: AnimationPlayer

var _max_hp: float = hp

func _ready() -> void:
	propagate_call("set_instance_shader_parameter", ["instance_id", randi() % 10000])

func apply_damage(damage: float) -> void:
	var start_hp := hp
	hp -= max(0, damage)
	var dealt := start_hp - hp
	damaged.emit(dealt)
	if dealt > 0:
		_animation_player.stop()
		_animation_player.play("damage")
		if is_zero_approx(hp):
			destroyed.emit()
