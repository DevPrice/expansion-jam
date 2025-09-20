extends PanelContainer

@export var _merch_container: Control
@export var _point_unlocks: Array[MerchUnlock]

@onready var _controller: ExpansionPlayerController = Controller.get_instigator(self)

func _ready() -> void:
	_controller.player_state.total_points_earned_changed.connect(_handle_unlocks, CONNECT_DEFERRED)
	_controller.player_state.trophy_unlocked.connect(hide, CONNECT_ONE_SHOT)
	_update_buttons(_controller.player_state.points)
	_handle_unlocks(_controller.player_state.total_points_earned)

func _handle_unlocks(total_points_earned: float) -> void:
	for unlock: MerchUnlock in _point_unlocks:
		if unlock and total_points_earned >= unlock.level:
			var node := get_node_or_null(unlock.unlock)
			if node: node.visible = true

func _process(_delta: float) -> void:
	_update_buttons(_controller.player_state.points)

func _update_buttons(points: float) -> void:
	for child: Node in _merch_container.get_children():
		if child is MerchButton:
			var was_disabled: bool = child.disabled
			child.disabled = points < child.cost
			if child.disabled != was_disabled:
				if child.disabled:
					child.propagate_call("add_theme_color_override", [&"default_color", child.get_theme_color(&"font_disabled_color")])
				else:
					child.propagate_call("remove_theme_color_override", [&"default_color"])
