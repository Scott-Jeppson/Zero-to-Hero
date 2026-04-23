extends Node

var game_state: String = "Main Menu"

# Player stats
var player_health: int = 100
var player_max_health: int = 100
var player_current_xp: float = 0.0
var player_xp_to_level_up: float = 50.0
var player_current_level: int = 0

signal state_changed(new_state: String)
signal health_changed(current_health: int, max_health: int)
signal experience_changed(current_xp: float, max_xp: float, level: int)

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

func update_health(current_health: int, max_health: int) -> void:
	"""Update player health and emit signal."""
	player_health = current_health
	player_max_health = max_health
	health_changed.emit(current_health, max_health)

func update_experience(current_xp: float, max_xp: float, level: int) -> void:
	"""Update player experience and emit signal."""
	player_current_xp = current_xp
	player_xp_to_level_up = max_xp
	player_current_level = level
	experience_changed.emit(current_xp, max_xp, level)
