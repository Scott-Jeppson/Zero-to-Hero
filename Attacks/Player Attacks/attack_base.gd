extends Area2D

# Base attack stats (export so subclasses can customize)
@export var base_damage: float = 10.0
@export var base_range: float = 100.0
@export var base_speed: float = 300.0
@export var base_size_multiplier: float = 1.0
@export var base_attack_cooldown: float = 1.0
@export var destroy_on_hit: bool = false  # Whether to destroy the attack on enemy hit

# Current stats
var current_damage: float
var current_range: float
var current_speed: float
var current_size_multiplier: float

# Track distance traveled
var distance_traveled: float = 0.0

# References
var player: Node2D
var hit_enemies: Array = []  # Track enemies already hit to avoid multiple hits


func _ready() -> void:
	# Find the player
	player = get_tree().get_first_node_in_group("player")
	
	# Initialize current stats
	current_damage = base_damage
	current_range = base_range
	current_speed = base_speed
	current_size_multiplier = base_size_multiplier
	
	# Add to attack group for identification
	add_to_group("attack")
	
	# Connect to collision signals
	body_entered.connect(_on_body_entered)
	
	# Apply size multiplier to the sprite
	if has_node("Sprite2D"):
		$Sprite2D.scale = Vector2.ONE * current_size_multiplier


func setup_direction(attack_direction: Vector2) -> void:
	"""Setup the attack direction. Call this after instantiation."""
	if has_meta("has_direction"):
		var meta_value = get_meta("has_direction")
		if meta_value:
			# This is a directional attack, set it up after _ready()
			call_deferred("set", "direction", attack_direction)


func _process(delta: float) -> void:
	# Move the attack
	move(delta)
	
	# Check if attack has traveled beyond its range
	if distance_traveled > current_range:
		destroy()


func move(delta: float) -> void:
	"""Move the attack. Subclasses can override for custom movement."""
	# Default: no movement. Subclasses override this.
	pass


func _on_body_entered(body: PhysicsBody2D) -> void:
	"""Called when the attack collides with a body."""
	# Only damage enemies
	if body.is_in_group("enemy"):
		# Avoid hitting the same enemy multiple times
		if body not in hit_enemies:
			hit_enemies.append(body)
			body.take_damage(current_damage)
			
			# Destroy on hit if configured
			if destroy_on_hit:
				destroy()


func get_damage() -> float:
	"""Return current damage with any modifiers applied."""
	return current_damage


func destroy() -> void:
	"""Remove this attack from the scene."""
	queue_free()
