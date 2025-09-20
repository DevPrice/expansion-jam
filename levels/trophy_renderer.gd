class_name TextureTileRenderer extends Node

@export var tilemap: GameTileMap
@export var texture: Texture2D
@export var tiles_per_second: float = 512

var _image: Image
var _current_tile: int = 0

func _physics_process(delta: float) -> void:
	if not _image: return
	var tiles_to_render: int = ceili(tiles_per_second * delta)
	var width := _image.get_width()
	var height := _image.get_height()
	while tiles_to_render > 0:
		if _current_tile >= width * height:
			_image = null
			break
		var tile_pos := Vector2i(_current_tile % width, _current_tile / width)
		var px := _image.get_pixelv(tile_pos)
		if px == Color.BLACK:
			tilemap.add_tile_with_hp(tile_pos - Vector2i(width, height) / 2, INF, false)
			_current_tile += 1
		else:
			_current_tile += 1
			continue
		tiles_to_render -= 1
	tilemap.bounds_changed.emit(tilemap.bounds)

func render_to_tilemap() -> void:
	_current_tile = 0
	_image = texture.get_image()
