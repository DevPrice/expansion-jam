extends Node

@onready var max_particles_per_second: int = ProjectSettings.get_setting(MAX_PARTICLES_PER_SECOND_SETTING_PATH, 180)

const MAX_PARTICLES_PER_SECOND_SETTING_PATH: String = "rendering/particles/max_particles_per_second"

func _ready() -> void:
	print(max_particles_per_second)
	for bus: int in AudioServer.bus_count:
		var bus_name := AudioServer.get_bus_name(bus)
		var volume: float = ProjectSettings.get_setting(get_volume_setting_path(bus_name), 1.0)
		AudioServer.set_bus_volume_linear(bus, volume)

func get_volume_setting_path(bus_name: String) -> String:
	return "audio/volume/%s" % bus_name
