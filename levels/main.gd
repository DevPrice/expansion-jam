extends Node2D

@export var tilemap: GameTileMap
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_unhandled_click(event)

func _unhandled_click(event: InputEventMouseButton) -> void:
	if event.button_index & MOUSE_BUTTON_MASK_LEFT:
		var cell_pos := _viewport_to_cell_pos(event.position)
		var node := tilemap.get_cell_tile(cell_pos)
		if node:
			node.apply_damage(1)

func _viewport_to_global_pos(viewport_pos: Vector2) -> Vector2:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	if not controller: return viewport_pos
	var center_relative := viewport_pos - get_viewport_rect().size * .5
	return center_relative * controller.camera.global_transform.affine_inverse() / controller.camera.zoom

func _viewport_to_cell_pos(viewport_pos: Vector2) -> Vector2i:
	var global_pos := _viewport_to_global_pos(viewport_pos)
	return tilemap.local_to_map(tilemap.to_local(global_pos))

func _get_node_at(global_pos: Vector2) -> Node:
	var map_pos := tilemap.local_to_map(tilemap.to_local(global_pos))
	return tilemap.get_cell_node(map_pos)
