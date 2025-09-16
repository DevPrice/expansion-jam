extends PanelContainer

@export var _merch_container: Control
@export var _point_unlocks: Array[MerchUnlock]

@onready var _controller: ExpansionPlayerController = Controller.get_instigator(self)

func _ready() -> void:
	_controller.player_state.points_changed.connect(_points_changed, CONNECT_DEFERRED)
	_update_buttons(_controller.player_state.points)

func _points_changed(points: float) -> void:
	_update_buttons(points)
	for unlock: MerchUnlock in _point_unlocks:
		if unlock and points >= unlock.level:
			var node := get_node_or_null(unlock.unlock)
			if node: node.visible = true

func _update_buttons(points: float) -> void:
	for child: Node in _merch_container.get_children():
		if child is MerchButton:
			child.disabled = points < child.cost
			if child.disabled:
				child.propagate_call("add_theme_color_override", [&"default_color", child.get_theme_color(&"font_disabled_color")])
			else:
				child.propagate_call("remove_theme_color_override", [&"default_color"])
