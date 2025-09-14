class_name GameTileMap extends TileMapLayer

var _scenes: Dictionary[Vector2i, Node]

func _enter_tree() -> void:
	child_entered_tree.connect(_child_entered)
	child_exiting_tree.connect(_child_exiting)

func _exit_tree() -> void:
	child_entered_tree.disconnect(_child_entered)
	child_exiting_tree.disconnect(_child_exiting)

func _child_entered(child: Node) -> void:
	_scenes[local_to_map(child.position)] = child

func _child_exiting(child: Node) -> void:
	_scenes.erase(local_to_map(child.position))

func get_cell_node(map_position: Vector2i) -> Node:
	return _scenes.get(map_position)
