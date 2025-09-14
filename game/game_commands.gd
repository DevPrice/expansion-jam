class_name GameCommands extends ConsoleCommands

func set_points(amount: int) -> void:
	var controller: ExpansionPlayerController = Players.get_primary_controller()
	controller.player_state.points = amount
