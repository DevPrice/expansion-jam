extends Node2D

@export var tilemap: GameTileMap
@export var player_ui_scene: PackedScene
@export var damage_particles_scene: PackedScene
@export var destroy_particles_scene: PackedScene

func _enter_tree() -> void:
	Players.player_joined.connect(_player_joined)
	get_viewport().size_changed.connect(_window_size_changed)

func _exit_tree() -> void:
	Players.player_joined.disconnect(_player_joined)
	get_viewport().size_changed.disconnect(_window_size_changed)

func _ready() -> void:
	# Warm these up to avoid stutter on first click
	_damage_effect(Vector2(10000000000.0, 0.0))
	_destroy_effect(Vector2(10000000000.0, 0.0))

func _physics_process(_delta: float) -> void:
	_particles_this_frame = 0

func _player_joined(controller: ExpansionPlayerController) -> void:
	var player := controller.get_local_player()
	if player_ui_scene and player:
		player.hud = player_ui_scene.instantiate()
		controller.claim(player.hud)
		var canvas_layer := CanvasLayer.new()
		canvas_layer.add_child(player.hud)
		canvas_layer.layer = 10
		player.get_viewport().add_child(canvas_layer)
	controller.camera.enabled = true
	controller.player_state.autoclick.connect(_autoclick)
	_init_game()
	_update_zoom(tilemap.bounds)

func _init_game() -> void:
	_update_zoom(tilemap.bounds, false)

func _tile_damaged(tile: Tile, damage: float) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	if not controller: return
	controller.player_state.points += damage * tile.point_value

func _tile_destroyed(tile: Tile) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	if not controller: return
	controller.player_state.points += controller.player_state.tile_bonus
	controller.player_state.autoclickers += controller.player_state.autoclicker_harvest
	controller.player_state.autoclicker_bonus_damage += controller.player_state.autoclicker_power_harvest
	_destroy_effect(tile.global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_unhandled_click(event)

func _autoclick(count: int) -> void:
	if count < 1: return
	var state := _get_player_state()
	var sample := Arrays.sample(tilemap.get_children(), count)
	sample.shuffle()
	for tile: Tile in sample:
		tile.apply_damage(state.get_autoclick_damage())
		_damage_effect(tile.global_position)

func _unhandled_click(event: InputEventMouseButton) -> void:
	if event.button_index & MOUSE_BUTTON_MASK_LEFT:
		var state := _get_player_state()
		var cell_pos := _viewport_to_cell_pos(event.position)
		for dx: int in range(-state.reach, state.reach + 1):
			for dy: int in range(-state.reach, state.reach + 1):
				var tile := tilemap.get_cell_tile(cell_pos + Vector2i(dx, dy))
				if tile:
					tile.apply_damage(state.get_click_damage())
					if dx == 0 and dy == 0:
						_damage_effect(_viewport_to_global_pos(event.position))
					else:
						_damage_effect(tile.global_position)
		var controller: ExpansionPlayerController = Players.get_primary_controller()
		if controller.player_state.leadership or true:
			_autoclick(controller.player_state.autoclickers)
		get_viewport().set_input_as_handled()

# TODO: Do something smarter to optimize this
var _particles_this_frame: int = 0
const _max_particles_per_frame: int = 10
func _damage_effect(location: Vector2) -> void:
	if _particles_this_frame > _max_particles_per_frame: return
	_particles_this_frame += 1
	var particles: GPUParticles2D = damage_particles_scene.instantiate()
	particles.global_position = location
	add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free, CONNECT_ONE_SHOT)

func _destroy_effect(location: Vector2) -> void:
	if _particles_this_frame > _max_particles_per_frame: return
	_particles_this_frame += 1
	var particles: GPUParticles2D = destroy_particles_scene.instantiate()
	particles.global_position = location
	add_child.call_deferred(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free, CONNECT_ONE_SHOT)

func _viewport_to_global_pos(viewport_pos: Vector2) -> Vector2:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	if not controller: return viewport_pos
	var center_relative := (viewport_pos + controller.camera.offset * controller.camera.zoom) - get_viewport_rect().size * .5
	return ((center_relative) / controller.camera.zoom) * controller.camera.global_transform.affine_inverse()

func _viewport_to_cell_pos(viewport_pos: Vector2) -> Vector2i:
	var global_pos := _viewport_to_global_pos(viewport_pos)
	return tilemap.local_to_map(tilemap.to_local(global_pos))

func _get_tile_at(global_pos: Vector2) -> Node:
	var map_pos := tilemap.local_to_map(tilemap.to_local(global_pos))
	return tilemap.get_cell_node(map_pos)

func _get_player_state() -> ExpansionPlayerState:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	return controller.player_state if controller else null

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
	var shop_width: float = controller.get_hud().get_node("Shop").size.x
	viewport_size.x -= shop_width

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
	var zoom_scale := viewport_size / world_span
	var zoom := minf(zoom_scale.x, zoom_scale.y)

	if tween_zoom:
		var tween := get_tree().create_tween()
		tween.tween_property(camera, "zoom", Vector2.ONE * zoom, 0.2)
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SPRING)
	else:
		camera.zoom = Vector2.ONE * zoom
	camera.offset.x = shop_width * .5 / zoom
