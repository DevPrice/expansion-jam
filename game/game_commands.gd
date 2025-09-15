class_name GameCommands extends ConsoleCommands

func set_points(amount: float) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	controller.player_state.points = amount

func set_autoclickers(amount: int) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	controller.player_state.autoclickers = amount

func damage_all(damage: float = 1.0) -> void:
	get_tree().root.propagate_call("apply_damage", [damage])
