extends PanelContainer

@export var _merch_container: Control

@onready var _controller: ExpansionPlayerController = Controller.get_instigator(self)

func _ready() -> void:
	_controller.player_state.points_changed.connect(_points_changed)
	_update_buttons(_controller.player_state.points)

func _points_changed(points: float) -> void:
	_update_buttons(points)

func _update_buttons(points: float) -> void:
	for child: Node in _merch_container.get_children():
		if child is MerchButton:
			child.disabled = points < child.cost
