class_name DeviceSettings

static func get_device_settings_path() -> String:
	return ProjectSettings.get_setting_with_override("application/config/project_settings_override")

static func get_renderer() -> Renderer:
	match ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method"):
		"forward_plus": return Renderer.FORWARD_PLUS
		"mobile": return Renderer.MOBILE
		_: return Renderer.COMPATIBILITY

static func delete_settings(property_paths: PackedStringArray) -> Error:
	var config_file := ConfigFile.new()
	var load_err := config_file.load(get_device_settings_path())
	if load_err == ERR_FILE_NOT_FOUND: return OK
	if load_err != OK: return load_err

	for path: String in property_paths:
		var section_separator := path.find("/")
		if section_separator == -1:
			if config_file.has_section(path):
				config_file.erase_section(path)
		else:
			var section := path.left(section_separator)
			var key := path.substr(section_separator + 1)
			if config_file.has_section_key(section, key):
				config_file.erase_section_key(section, key)

	return config_file.load(get_device_settings_path())

static func store_settings(settings: Dictionary[String, Variant], settings_registry: Object = ProjectSettings) -> Error:
	var config_file := ConfigFile.new()
	var load_err := config_file.load(get_device_settings_path())
	if load_err and load_err != ERR_FILE_NOT_FOUND:
		return load_err

	for setting_path: String in settings:
		var value: Variant = settings[setting_path]
		var parts := setting_path.split("/")
		assert(parts.size() > 1, "Invalid setting path %s!" % setting_path)
		config_file.set_value(parts[0], "/".join(parts.slice(1)), value)
		if settings_registry: settings_registry.set(setting_path, value)

	return config_file.save(get_device_settings_path())

static func delete_settings_overrides() -> Error:
	var settings_path := ProjectSettings.get_setting_with_override("application/config/project_settings_override")
	if FileAccess.file_exists(settings_path):
		return DirAccess.remove_absolute(settings_path)
	return OK

enum Renderer {
	FORWARD_PLUS,
	MOBILE,
	COMPATIBILITY,
}
