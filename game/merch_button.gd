class_name MerchButton extends Button

signal purchased
signal level_changed

@export var _title_label: RichTextLabel
@export var _description_label: RichTextLabel
@export var _cost_label: RichTextLabel

@export var title: String:
	get(): return _title_label.text
	set(value):
		_title_label.text = value

@export var description: String:
	get(): return _description_label.text
	set(value):
		_description_label.text = value

@export var cost: float:
	set(value):
		cost = value
		_cost_label.text = "$ %s" % NumFormat.format_points(value)

@export var cost_curve: Curve

@export var unlock_on_purchase: Array[Node]

var level: int = 0:
	set(value):
		level = value
		level_changed.emit(value)

@onready var _controller: ExpansionPlayerController = Controller.get_instigator(self)

func _ready() -> void:
	_update_cost()

func _pressed() -> void:
	if not _controller: return
	if _controller.player_state.points >= cost:
		_controller.player_state.points -= cost
		level += 1
		_update_cost()
		_purchased()
		_unlock()
		purchased.emit()
		if not cost_curve:
			queue_free()

func _purchased() -> void:
	pass

func _update_cost() -> void:
	if cost_curve:
		if level <= cost_curve.max_domain:
			cost = cost_curve.sample(level)
		else:
			queue_free()

func _unlock() -> void:
	for node: Control in unlock_on_purchase:
		node.visible = true
	unlock_on_purchase.clear()
