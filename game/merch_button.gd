class_name MerchButton extends Button

@export var _title_label: RichTextLabel
@export var _description_label: RichTextLabel

@export var title: String:
	get(): return _title_label.text
	set(value):
		_title_label.text = value

@export var description: String:
	get(): return _description_label.text
	set(value):
		_description_label.text = value
