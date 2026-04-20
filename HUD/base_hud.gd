extends CanvasLayer
## Base HUD class that ensures all HUD elements remain interactive and process even when the game is paused

func _ready() -> void:
	# Ensure HUD always processes even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
