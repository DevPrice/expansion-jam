class_name Tile extends Node2D

signal damaged(damage: float)
signal destroyed

const MAX_DAMAGED_TILES: int = 200
static var _damaged_tile_count: int = 0
var enable_instance_shader_params: bool = false

var _is_damaged: bool = false

@export var hp: float = 1:
	set(value):
		hp = maxf(0, value)
		_max_hp = maxf(_max_hp, value)
		if not is_equal_approx(hp, _max_hp) and not _is_damaged and _damaged_tile_count < MAX_DAMAGED_TILES:
			_is_damaged = true
			_damaged_tile_count += 1
			_texture_rect.material = _damagable_material
			propagate_call("set_instance_shader_parameter", ["instance_id", randi() % 10000])
		if _is_damaged:
			propagate_call("set_instance_shader_parameter", ["damage", 1.0 - hp / _max_hp])

@export var point_value: float = 1

@export var _animation_player: AnimationPlayer

@export var _texture_rect: Control
@export var _damagable_material: Material

var _max_hp: float = hp

func _exit_tree() -> void:
	if _is_damaged:
		_damaged_tile_count -= 1

func get_max_hp() -> float:
	return _max_hp

func apply_damage(damage: float) -> void:
	var start_hp := hp
	hp -= max(0, damage)
	var dealt := start_hp - hp
	damaged.emit(dealt)
	if dealt > 0:
		_animation_player.stop()
		_animation_player.play("damage")
		if is_zero_approx(hp):
			hp = 0.0
			destroyed.emit()

func _mouse_entered() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", 1.1 * Vector2.ONE, .05)
	tween.set_trans(Tween.TRANS_SPRING)

func _mouse_exited() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", 1.0 * Vector2.ONE, .1)
	tween.set_trans(Tween.TRANS_SPRING)
