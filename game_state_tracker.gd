extends Node

var game_state: String = "Main Menu"

signal state_changed(new_state: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state("Main Menu")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func change_state(new_state: String) -> void:
	if game_state != new_state:
		game_state = new_state
		state_changed.emit(new_state)