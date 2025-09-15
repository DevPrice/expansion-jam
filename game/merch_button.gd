class_name MerchButton extends Button

signal purchased

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

func _pressed() -> void:
	var controller: ExpansionPlayerController = Controller.get_instigator(self)
	if not controller: return
	if controller.player_state.points >= cost:
		controller.player_state.points -= cost
		purchased.emit()
		_purchased()

func _purchased() -> void:
	pass
