class_name GameTileMap extends TileMapLayer

signal tile_destroyed(tile: Tile)
signal bounds_changed(bounds: Rect2i)

var _scenes: Dictionary[Vector2i, Node]
var bounds: Rect2i

func _ready() -> void:
	for tile: Vector2i in get_used_cells():
		_update_bounds(tile)
	bounds_changed.emit(bounds)

func _enter_tree() -> void:
	child_entered_tree.connect(_child_entered)
	child_exiting_tree.connect(_child_exiting)

func _exit_tree() -> void:
	child_entered_tree.disconnect(_child_entered)
	child_exiting_tree.disconnect(_child_exiting)

func _child_entered(child: Node) -> void:
	_scenes[local_to_map(child.position)] = child
	if child is Tile:
		child.destroyed.connect(_tile_destroyed.bind(child))

func _child_exiting(child: Node) -> void:
	_scenes.erase(local_to_map(child.position))

func get_cell_tile(map_position: Vector2i) -> Tile:
	return _scenes.get(map_position)

func _tile_destroyed(tile: Tile) -> void:
	var cell_pos := local_to_map(tile.position)
	for neighbor_pos: Vector2i in get_surrounding_cells(cell_pos):
		if get_cell_source_id(neighbor_pos) == -1:
			add_tile(neighbor_pos, false)
	set_cell(cell_pos, 1, Vector2.ZERO)
	tile_destroyed.emit(tile)
	bounds_changed.emit(bounds)

func add_tile(map_pos: Vector2i, emit_bounds_changed: bool = true) -> void:
	set_cell(map_pos, 0, Vector2i.ZERO, 1)
	_update_bounds(map_pos)
	if emit_bounds_changed: bounds_changed.emit(bounds)

func _update_bounds(new_pos: Vector2i) -> void:
	bounds = bounds.expand(new_pos)

enum TileType {
	EMPTY = 2,
	BASIC = 1,
}
