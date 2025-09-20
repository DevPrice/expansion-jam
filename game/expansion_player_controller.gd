class_name ExpansionPlayerController extends PlayerController

@export var player_state: ExpansionPlayerState
@export var camera: Camera2D

func get_game_hud() -> GameHud:
	return get_hud()
