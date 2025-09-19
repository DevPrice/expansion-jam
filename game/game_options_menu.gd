extends ConfigMenu

@export
var window_mode: Window.Mode:
	get:
		var mode := get_window().mode
		match mode:
			Window.MODE_MAXIMIZED, Window.MODE_MINIMIZED: return Window.MODE_WINDOWED
			_: return mode
	set(value):
		get_window().mode = value
		DeviceSettings.store_setting("display/window/size/mode", value)

@export
var particle_density: ParticleDensity:
	get: return GameSettings.max_particles_per_tick as ParticleDensity
	set(value):
		GameSettings.max_particles_per_tick = value
		DeviceSettings.store_setting(GameSettings.MAX_PARTICLES_PER_TICK_SETTING_PATH, value)

@export_range(0.0, 1.0, 0.025)
var master_volume: float:
	get:
		var bus := AudioServer.get_bus_index("Master")
		return AudioServer.get_bus_volume_linear(bus)
	set(value):
		var bus := AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_linear(bus, value)
		DeviceSettings.store_setting(GameSettings.get_volume_setting_path("Master"), value)

@export_range(0.0, 1.0, 0.025)
var music_volume: float:
	get:
		var bus := AudioServer.get_bus_index("Music")
		return AudioServer.get_bus_volume_linear(bus)
	set(value):
		var bus := AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_linear(bus, value)
		DeviceSettings.store_setting(GameSettings.get_volume_setting_path("Music"), value)

@export_range(0.0, 1.0, 0.025)
var effects_volume: float:
	get:
		var bus := AudioServer.get_bus_index("Effects")
		return AudioServer.get_bus_volume_linear(bus)
	set(value):
		var bus := AudioServer.get_bus_index("Effects")
		AudioServer.set_bus_volume_linear(bus, value)
		DeviceSettings.store_setting(GameSettings.get_volume_setting_path("Effects"), value)

@export
var vsync: bool:
	get: return DisplayServer.window_get_vsync_mode(get_window().get_window_id())
	set(value):
		var vsync_mode := DisplayServer.VSyncMode.VSYNC_ENABLED if value else DisplayServer.VSyncMode.VSYNC_DISABLED
		DisplayServer.window_set_vsync_mode(vsync_mode, get_window().get_window_id())
		DeviceSettings.store_setting("display/window/vsync/vsync_mode", vsync_mode)

@export
var cap_frame_rate: bool:
	get: return Engine.max_fps != 0

@export_range(0, 999, 1, "suffix:fps")
var max_frame_rate: int:
	get: return Engine.max_fps
	set(value):
		Engine.max_fps = value
		DeviceSettings.store_setting("application/run/max_fps", value)

@export_custom(PROPERTY_HINT_TOOL_BUTTON, "Quit", PROPERTY_USAGE_EDITOR)
var quit_game: Callable = close_game

func _enter_tree() -> void:
	super._enter_tree()
	# In case the window mode changed (there is no mode-specific signal)
	# Note: Sometimes the mode can change without the size changing :(
	get_window().size_changed.connect(notify_property_list_changed)

func _exit_tree() -> void:
	super._exit_tree()
	get_window().size_changed.disconnect(notify_property_list_changed)

func close_game() -> void:
	DisplayServer.dialog_show(
		"Quit game?",
		"Are you sure you want to quit? Your progress with not be saved.",
		PackedStringArray(["Quit", "Cancel"]),
		_option_selected,
	)

func _option_selected(option: int) -> void:
	if not option: get_tree().quit()

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"vsync", &"cap_frame_rate", &"max_frame_rate", &"quit_game" when OS.has_feature("web"):
			property.usage &= ~PROPERTY_USAGE_EDITOR
		&"max_frame_rate" when not get_pending_value(&"cap_frame_rate"):
			property.usage |= PROPERTY_USAGE_READ_ONLY
		&"window_mode" when OS.has_feature("web"):
			property.hint_string = "Windowed:0,Fullscreen:3"
		&"window_mode":
			property.hint_string = "Windowed:0,Fullscreen:3,Exclusive fullscreen:4"

func _config_changed(config: StringName, value: Variant) -> void:
	match config:
		&"cap_frame_rate":
			if value:
				if get_pending_value(&"max_frame_rate") == 0:
					set_pending_value(&"max_frame_rate", DisplayServer.screen_get_refresh_rate(get_window().current_screen))
			else:
				set_pending_value(&"max_frame_rate", 0)

func _create_header(property_info: Dictionary) -> Control:
	var label := _create_label(property_info)
	label.theme_type_variation = "HeaderMedium" if property_info.usage & PROPERTY_USAGE_GROUP else "HeaderSmall"
	return label

func _create_container(property_info: Dictionary) -> Control:
	var container := VBoxContainer.new()
	container.theme_type_variation = "SettingLabel"
	container.tooltip_text = _get_tooltip_text(property_info.name)
	container.visible = property_info.usage & PROPERTY_USAGE_EDITOR
	return container

enum ParticleDensity {
	DISABLED = 0,
	LOW = 1,
	MEDIUM = 3,
	HIGH = 5,
}
