extends Node2D

@export var tilemap: TileMapLayer
@export var player_ui_scene: PackedScene

func _enter_tree() -> void:
	Players.player_joined.connect(_player_joined)

func _exit_tree() -> void:
	Players.player_joined.disconnect(_player_joined)

func _player_joined(controller: PlayerController) -> void:
	var player := controller.get_local_player()
	if player_ui_scene and player:
		player.hud = player_ui_scene.instantiate()
		var canvas_layer := CanvasLayer.new()
		canvas_layer.add_child(player.hud)
		canvas_layer.layer = 10
		player.get_viewport().add_child(canvas_layer)
	_init_game()

func _init_game() -> void:
	pass
