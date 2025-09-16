class_name GameCommands extends ConsoleCommands

func _context() -> Dictionary[String, Variant]:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	return {
		"_PLAYER_STATE": controller.player_state if controller else null
	}

func set_points(amount: float) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	controller.player_state.points = amount

func set_autoclickers(amount: int) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	controller.player_state.autoclickers = amount

func set_reach(amount: int) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	controller.player_state.reach = amount

func damage_all(damage: float = 1.0) -> void:
	get_tree().root.propagate_call("apply_damage", [damage])
