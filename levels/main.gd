extends Node2D

@export var tilemap: GameTileMap
@export var player_ui_scene: PackedScene

func _enter_tree() -> void:
	Players.player_joined.connect(_player_joined)
	get_viewport().size_changed.connect(_window_size_changed)

func _exit_tree() -> void:
	Players.player_joined.disconnect(_player_joined)
	get_viewport().size_changed.disconnect(_window_size_changed)

func _player_joined(controller: PlayerController) -> void:
	var player := controller.get_local_player()
	if player_ui_scene and player:
		player.hud = player_ui_scene.instantiate()
		controller.claim(player.hud)
		var canvas_layer := CanvasLayer.new()
		canvas_layer.add_child(player.hud)
		canvas_layer.layer = 10
		player.get_viewport().add_child(canvas_layer)
	_init_game()
	_update_zoom(tilemap.bounds)

func _init_game() -> void:
	_update_zoom(tilemap.bounds, false)

func _tile_destroyed(tile: Tile) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	if not controller: return
	controller.player_state.points += tile.point_value

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_unhandled_click(event)

func _unhandled_click(event: InputEventMouseButton) -> void:
	if event.button_index & MOUSE_BUTTON_MASK_LEFT:
		var cell_pos := _viewport_to_cell_pos(event.position)
		var tile := tilemap.get_cell_tile(cell_pos)
		if tile:
			tile.apply_damage(1.0)
			get_viewport().set_input_as_handled()

func _viewport_to_global_pos(viewport_pos: Vector2) -> Vector2:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	if not controller: return viewport_pos
	var center_relative := viewport_pos - get_viewport_rect().size * .5
	return (center_relative / controller.camera.zoom) * controller.camera.global_transform.affine_inverse()

func _viewport_to_cell_pos(viewport_pos: Vector2) -> Vector2i:
	var global_pos := _viewport_to_global_pos(viewport_pos)
	return tilemap.local_to_map(tilemap.to_local(global_pos))

func _get_tile_at(global_pos: Vector2) -> Node:
	var map_pos := tilemap.local_to_map(tilemap.to_local(global_pos))
	return tilemap.get_cell_node(map_pos)

func _bounds_changed(bounds: Rect2i) -> void:
	_update_zoom(bounds)

func _window_size_changed() -> void:
	_update_zoom(tilemap.bounds, false)

func _update_zoom(bounds: Rect2i, tween_zoom: bool = true) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	if not controller: return
	var camera := controller.camera
	var tile_bounds := tilemap.bounds.grow(2)
	var tile_size := tilemap.tile_set.tile_size
	var viewport_size := Vector2(camera.get_viewport().size)

	var world_bounds := Rect2(
		tile_bounds.position * tile_size,
		tile_bounds.size * tile_size,
	)

	var dx := maxf(
		camera.global_position.x - world_bounds.position.x,
		world_bounds.position.x + world_bounds.size.x - camera.global_position.x
	)
	var dy := maxf(
		camera.global_position.y - world_bounds.position.y,
		world_bounds.position.y + world_bounds.size.y - camera.global_position.y
	)

	var world_span := Vector2(dx, dy) * 2.0
	var zoom := viewport_size / world_span

	if zoom > camera.zoom:
		if tween_zoom:
			var tween := get_tree().create_tween()
			tween.tween_property(camera, "zoom", Vector2.ONE * minf(zoom.x, zoom.y), 0.2)
			tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SPRING)
		else:
			camera.zoom = Vector2.ONE * minf(zoom.x, zoom.y)
