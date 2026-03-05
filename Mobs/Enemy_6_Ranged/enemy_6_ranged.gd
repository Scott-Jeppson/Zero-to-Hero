extends "../mob_base.gd"

@export var desired_distance: float = 200.0  # Distance to maintain from player
@export var attack_range: float = 250.0  # Distance within which to fire ranged attacks
@export var attack_cooldown_time: float = 2.0  # Time between ranged attacks

var attack_cooldown: float = 0.0  # Current cooldown timer


func _ready() -> void:
	# Set custom base stats for this enemy type
	base_health = 10.0
	base_speed = 100.0
	base_attack_power = 5.0	
	experience_drop_value = 25.0	
	# Call parent initialization
	super._ready()
	
	# Start with no cooldown
	attack_cooldown = 0.0


func _process(delta: float) -> void:
	# Call parent process for movement
	super._process(delta)
	
	# Update attack cooldown
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	else:
		# Fire ranged attack when cooldown is ready
		_fire_ranged_attack()
		attack_cooldown = attack_cooldown_time


func move() -> void:
	"""Move to maintain desired distance from player. Stop completely at desired distance."""
	if not player:
		linear_velocity = Vector2.ZERO
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# If player is beyond desired distance, move closer
	if distance_to_player > desired_distance:
		var direction = (player.global_position - global_position).normalized()
		linear_velocity = direction * current_speed
	else:
		# At or within desired distance, stop all movement
		linear_velocity = Vector2.ZERO


func _fire_ranged_attack() -> void:
	"""Fire a ranged attack at the player. Only fires if player is within attack range."""
	if not player:
		return
	
	# Check if player is within attack range
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > attack_range:
		return
	
	# TODO: Implement projectile spawning here
	# For now, this is just a placeholder
	print("Enemy 6 fires ranged attack with power: ", current_attack_power)
