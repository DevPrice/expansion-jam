class_name PlayerController extends Controller

@export var player: Player

func get_hud() -> Control:
	if player is LocalPlayer:
		return player.hud
	return null
