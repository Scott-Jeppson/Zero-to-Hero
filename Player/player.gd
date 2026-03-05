extends Area2D
signal died
signal experience_changed(current_xp: float, max_xp: float, level: int)
signal level_up

@export var speed = 200
@export var hit_points = 100
@export var strength = 1
@export var regen = 1
@export var attack_speed = 1.0
@export var attack_range = 1.0
@export var attack_size = 1.0
@export var projectile_speed = 1.0
var game_paused: bool = true

# Max health tracking
var max_hit_points = 100

# Experience and leveling
var current_xp: float = 0.0
var current_level: int = 0
var xp_to_level_up: float = 50.0  # XP needed for next level
var xp_per_level_multiplier: float = 1.2  # Each level requires 1.5x more XP

var colliding_enemies = []  # Track enemies currently colliding with player
var damage_cooldown = 0.0  # Timer for damage application

# Attack system
var active_attacks: Array = []  # List of active attacks (dictionaries with scene_path and cooldown)
var attack_cooldowns: Dictionary = {}  # Tracks current cooldown for each attack

# Regen tracking
var time_since_last_damage: float = 0.0
var regen_cooldown: float = 0.0


func _ready() -> void:
	# Add to player group for detection by other systems
	add_to_group("player")
	
	# Initialize max health
	hit_points = max_hit_points
	
	# Connect to body collision signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Connect to area collision for experience pickup
	area_entered.connect(_on_area_entered)
	
	
func _process(delta: float) -> void:
	if game_paused:
		return
	# Stop movement if dead
	if hit_points <= 0:
		return
	
	# Update time since last damage
	time_since_last_damage += delta
	
	# Apply regen if no damage taken for 2 seconds
	if time_since_last_damage >= 2.0:
		_apply_regen(delta)
	
	# Handle movement
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	if velocity.x != 0:
		$Sprite2D.flip_v = false
		$Sprite2D.flip_h = velocity.x < 0
		
	position += velocity * delta
	
	# Apply damage from colliding enemies every second
	_apply_enemy_damage(delta)
	
	# Update and launch attacks
	_update_attacks(delta)



func _apply_enemy_damage(delta: float) -> void:
	if game_paused:
		return
	"""Apply damage from colliding enemies. Damage has a 1 second cooldown."""
	if colliding_enemies.is_empty():
		damage_cooldown = 0.0
		return
	
	# Decrease cooldown
	if damage_cooldown > 0.0:
		damage_cooldown -= delta
		return
	
	# Cooldown is ready, apply damage
	var total_damage = 0.0
	
	# Sum up attack power from all colliding enemies
	for enemy in colliding_enemies:
		if is_instance_valid(enemy):  # Check if enemy still exists
			total_damage += enemy.get_attack_power()
	
	if total_damage > 0:
		take_damage(total_damage)
		damage_cooldown = 1.0  # Start cooldown


func _on_body_entered(body: PhysicsBody2D) -> void:
	"""Called when the player collides with a physics body."""
	if body.is_in_group("enemy"):
		if body not in colliding_enemies:
			colliding_enemies.append(body)


func _on_body_exited(body: PhysicsBody2D) -> void:
	"""Called when the player stops colliding with a physics body."""
	colliding_enemies.erase(body)


func _on_area_entered(area: Area2D) -> void:
	"""Called when an area enters the player (for experience pickup)."""
	if area.is_in_group("experience"):
		# Experience orb will handle the pickup, just needed collision detection
		pass


func add_attack(attack_scene_path: String, cooldown: float) -> void:
	"""Add an attack to the player's active attacks."""
	active_attacks.append({
		"scene_path": attack_scene_path,
		"base_cooldown": cooldown
	})
	attack_cooldowns[attack_scene_path] = 0.0  # Ready to fire immediately


func _update_attacks(delta: float) -> void:
	"""Update attack cooldowns and spawn attacks when ready."""
	for attack in active_attacks:
		var attack_path = attack["scene_path"]
		var base_cooldown = attack["base_cooldown"]
		var adjusted_cooldown = base_cooldown / attack_speed  # Higher attack_speed = lower cooldown
		
		# Decrease cooldown
		if attack_cooldowns[attack_path] > 0.0:
			attack_cooldowns[attack_path] -= delta
		else:
			# Cooldown is ready, spawn the attack
			_spawn_attack(attack_path)
			attack_cooldowns[attack_path] = adjusted_cooldown


func _spawn_attack(attack_scene_path: String) -> void:
	if game_paused:
		return
	"""Spawn an attack from the player's location."""
	var attack_scene = load(attack_scene_path)
	var attack = attack_scene.instantiate()
	
	# Add attack to the scene FIRST
	get_parent().add_child(attack)
	
	# Set attack position to player position
	attack.global_position = global_position
	
	# Apply player stat multipliers to attack
	if "base_range" in attack:
		attack.base_range *= attack_range
	if "base_size_multiplier" in attack:
		attack.base_size_multiplier *= attack_size
	if "base_speed" in attack:
		attack.base_speed *= projectile_speed
	if "base_damage" in attack:
		attack.base_damage *= strength
	
	# Try to set direction for directional attacks
	var closest_enemy = _get_closest_enemy()
	if closest_enemy:
		# Direction to closest enemy
		if "direction" in attack:
			attack.direction = (closest_enemy.global_position - global_position).normalized()
	else:
		# Random direction if no enemies
		if "direction" in attack:
			attack.direction = Vector2.from_angle(randf() * TAU)


func _get_closest_enemy() -> Node2D:
	"""Find and return the closest enemy to the player, or null if none exist."""
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	
	if all_enemies.is_empty():
		return null
	
	var closest_enemy = all_enemies[0]
	var closest_distance = global_position.distance_to(closest_enemy.global_position)
	
	for enemy in all_enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy


func take_damage(damage: float) -> void:
	"""Reduce player health by the given damage amount."""
	hit_points -= damage
	time_since_last_damage = 0.0  # Reset regen timer
	if hit_points <= 0:
		die()


func _apply_regen(delta: float) -> void:
	if game_paused:
		return
	"""Apply health regeneration if player hasn't been damaged for 2 seconds."""
	regen_cooldown -= delta
	
	# Regenerate health every second
	if regen_cooldown <= 0.0:
		hit_points = min(hit_points + regen, max_hit_points)
		regen_cooldown = 1.0  # Regen once per second


func die():
	hide() # Player disappears after dieing.
	died.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func gain_experience(amount: float) -> void:
	"""Gain experience and check for level up."""
	current_xp += amount
	
	# Emit signal for HUD to update
	experience_changed.emit(current_xp, xp_to_level_up, current_level)
	
	# Check if leveled up
	while current_xp >= xp_to_level_up:
		_level_up()


func _level_up() -> void:
	"""Handle leveling up - increase all stats by a small amount."""
	current_xp -= xp_to_level_up
	current_level += 1
	
	# Increase XP required for next level
	xp_to_level_up *= xp_per_level_multiplier
	
	# Increase all stats
	max_hit_points += 10
	hit_points += 10
	strength += 0.1
	speed += 2
	regen += 1
	attack_speed += 0.1
	projectile_speed += 0.1
	attack_range += 0.1
	attack_size += 0.1
	
	# Emit signals
	experience_changed.emit(current_xp, xp_to_level_up, current_level)
	level_up.emit()
