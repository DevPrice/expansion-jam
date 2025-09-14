extends Node2D

@export var tilemap: TileMapLayer

func _enter_tree() -> void:
	Players.player_joined.connect(_player_joined)

func _exit_tree() -> void:
	Players.player_joined.disconnect(_player_joined)

func _player_joined(_controller: PlayerController) -> void:
	_init_game()

func _init_game() -> void:
	pass
