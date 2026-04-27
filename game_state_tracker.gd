extends Node

var player: Node2D
var game_state: String = "Main Menu"
var player_stat_dict: Dictionary

# Player stats
@export var player_health: int = 100
@export var player_max_health: int = 100
@export var player_current_xp: float = 0.0
@export var player_xp_to_level_up: float = 50.0
@export var player_current_level: int = 0
@export var player_speed: int = 200
@export var player_strength: float = 1.0
@export var player_regen: float = 1.0
@export var player_attack_speed: float = 1.0
@export var player_attack_range: float = 1.0
@export var player_attack_size: float = 1.00
@export var player_projectile_speed: float = 1.0

# Experience and leveling
@export var current_xp: float = 0.0
@export var current_level: int = 0
@export var xp_to_level_up: float = 50.0  # XP needed for next level
@export var xp_per_level_multiplier: float = 1.2  # Each level requires 1.5x more XP

signal state_changed(new_state: String)
signal player_health_changed(current_health: int, max_health: int)
signal death
signal experience_changed(current_xp: float, max_xp: float, level: int)
signal level_up
signal player_stat_changed(stats: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state("Main Menu")
	player = get_tree().get_first_node_in_group("player")

	get_tree().node_added.connect(_on_node_added)
	await get_tree().process_frame
	_try_bind_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _try_bind_player() -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		_bind_player(p)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("player"):
		_bind_player(node)

func _bind_player(node: Node) -> void:
	if player == node:
		return

	player = node as Node2D
	_emit_full_stats()
	if not node.health_changed.is_connected(update_health):
		node.health_changed.connect(update_health)

func change_state(new_state: String) -> void:
	if game_state != new_state:
		game_state = new_state
		state_changed.emit(new_state)

func _emit_full_stats() -> void:
	player_stat_dict = {
		"health": player_health,
		"max_health": player_max_health,
		"current_xp": player_current_xp,
		"xp_to_level_up": player_xp_to_level_up,
		"current_level": player_current_level,
		"speed": player_speed,
		"strength": player_strength,
		"regen": player_regen,
		"attack_speed": player_attack_speed,
		"attack_range": player_attack_range,
		"attack_size": player_attack_size,
		"projectile_speed": player_projectile_speed
	}
	player_stat_changed.emit(player_stat_dict)

func update_health(change: int, max_health: int = player_max_health) -> void:
	"""Update player health and emit signal."""
	player_health += change
	if max_health != player_max_health:
		player_max_health = max_health
	if player_health < 0:
		player_health = 0
	player_health_changed.emit(player_health, player_max_health)
	if player_health == 0:
		death.emit()

func update_experience(xp_change) -> void:
	"""Update player experience and emit signal."""
	player_current_xp += xp_change
