extends RigidBody2D

# Base stats (export so subclasses can customize)
@export var base_health: float = 10.0
@export var base_speed: float = 100.0
@export var base_attack_power: float = 5.0

# Scaling factor per second (how quickly stats increase over time)
@export var health_scale: float = 0.5
@export var speed_scale: float = 0.2
@export var attack_power_scale: float = 0.1

# Experience drop
@export var experience_drop_value: float = 10.0

# Current stats
var current_health: float
var current_speed: float
var current_attack_power: float

# References
var player: Node2D


func _ready() -> void:
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("players")
		# Add this enemy to the "enemy" group for collision detection
	add_to_group("enemy")
		# Scale stats based on current game/round time when this enemy spawns
	_apply_game_time_scaling()


func _process(delta: float) -> void:
	# Move towards player if they exist
	if player:
		move()


func _apply_game_time_scaling() -> void:
	"""Apply stat scaling based on game/round time at spawn. Only called once in _ready()."""
	var game_time = _get_game_time()
	current_health = base_health + (health_scale * game_time)
	current_speed = base_speed + (speed_scale * game_time)
	current_attack_power = base_attack_power + (attack_power_scale * game_time)


func _get_game_time() -> float:
	"""Get the current game/round time. Override or set up a game manager to track this."""
	# Try to get from a game manager autoload (you'll need to create this)
	if Engine.has_meta("game_time"):
		return Engine.get_meta("game_time")
	
	# Fallback: return how long the player has been alive
	if player and player.has_meta("time_alive"):
		return player.get_meta("time_alive")
	
	# Fallback: return 0 if no game manager is set up
	return 0.0


func move() -> void:
	"""Move towards the player. Subclasses can override for custom movement."""
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	
	# Move in the calculated direction
	linear_velocity = direction * current_speed


func take_damage(damage: float) -> void:
	"""Apply damage to this mob."""
	current_health -= damage
	
	if current_health <= 0:
		die()


func die() -> void:
	"""Called when the mob's health reaches 0. Drops experience and is removed."""
	_drop_experience()
	queue_free()


func _drop_experience() -> void:
	"""Drop an experience orb at this mob's location."""
	var experience_scene = load("res://Experience/experience.tscn")
	if not experience_scene:
		return
	
	var experience_orb = experience_scene.instantiate()
	experience_orb.experience_value = experience_drop_value
	experience_orb.global_position = global_position
	
	# Add to the scene (parent of the mob, which should be the main scene)
	get_parent().add_child(experience_orb)


func get_attack_power() -> float:
	"""Return current attack power with scaling applied."""
	return current_attack_power
