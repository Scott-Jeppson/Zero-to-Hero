extends "res://HUD/base_hud.gd"
## Main menu HUD that displays the title and start button

func _on_start_pressed() -> void:
	"""Called when the start button is pressed."""
	GameStateTracker.change_state("Playing")
