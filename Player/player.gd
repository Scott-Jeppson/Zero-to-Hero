extends Area2D
signal health_changed(change: int)
signal experience_changed(change: int)

var colliding_enemies = []  # Track enemies currently colliding with player
var damage_cooldown = 0.0  # Timer for damage application

# Attack system
var active_attacks: Array = []  # List of active attacks (dictionaries with scene_path and cooldown)
var attack_cooldowns: Dictionary = {}  # Tracks current cooldown for each attack

# Regen tracking
var time_since_last_damage: float = 0.0
var regen_cooldown: float = 1.0

var stats: Dictionary

func _ready() -> void:
	# Add to player group for detection by other systems
	add_to_group("player")
	
	# Setting up to receive stats from tracker
	GameStateTracker.player_stat_changed.connect(_update_stats)
	GameStateTracker.death.connect(die)
	
	# Initialize stats
	_update_stats(GameStateTracker.player_stat_dict)
	
	# Connect to body collision signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Connect to area collision for experience pickup
	area_entered.connect(_on_area_entered)
	
	
func _process(delta: float) -> void:
	
	# Update time since last damage
	time_since_last_damage += delta
	
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
		velocity = velocity.normalized() * stats.get("speed", 200)
		
	if velocity.x != 0:
		$Sprite2D.flip_v = false
		$Sprite2D.flip_h = velocity.x < 0
		
	position += velocity * delta
	
	# Apply damage from colliding enemies every second
	_apply_enemy_damage(delta)
	
	# Apply regeneration
	_apply_regen(delta)
	
	# Update and launch attacks
	_update_attacks(delta)

func _update_stats(new_stats: Dictionary) -> void:
	stats = new_stats

func _apply_enemy_damage(delta: float) -> void:
	"""Apply damage from colliding enemies. Damage has a 1 second cooldown."""
	# Decrease cooldown
	if damage_cooldown - delta > 0.0:
		damage_cooldown -= delta
		return
	
	if colliding_enemies.is_empty():
		return
	
	# Cooldown is ready, apply damage
	var total_damage = 0.0
	
	# Sum up attack power from all colliding enemies
	for enemy in colliding_enemies:
		if is_instance_valid(enemy):  # Check if enemy still exists
			total_damage += enemy.get_attack_power()
	
	if total_damage > 0:
		regen_cooldown = 2.0  # Reset regen cooldown on damage
		health_changed.emit(-total_damage)
		damage_cooldown = 1.0 + (delta - damage_cooldown) # Start cooldown

	total_damage = 0.0  # Reset total damage after applying


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
		var adjusted_cooldown = base_cooldown / stats["attack_speed"]  # Higher attack_speed = lower cooldown
		
		# Decrease cooldown
		if attack_cooldowns[attack_path] > 0.0:
			attack_cooldowns[attack_path] -= delta
		else:
			# Cooldown is ready, spawn the attack
			_spawn_attack(attack_path)
			attack_cooldowns[attack_path] = adjusted_cooldown


func _spawn_attack(attack_scene_path: String) -> void:
	"""Spawn an attack from the player's location."""
	var attack_scene = load(attack_scene_path)
	var attack = attack_scene.instantiate()
	
	# Add attack to the scene FIRST
	get_parent().add_child(attack)
	
	# Set attack position to player position
	attack.global_position = global_position
	
	# Apply player stat multipliers to attack
	if "base_range" in attack:
		attack.base_range *= stats["attack_range"]
	if "base_size_multiplier" in attack:
		attack.base_size_multiplier *= stats["attack_size"]
	if "base_speed" in attack:
		attack.base_speed *= stats["projectile_speed"]
	if "base_damage" in attack:
		attack.base_damage *= stats["strength"]
	
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

func _apply_regen(delta: float) -> void:
	"""Apply health regeneration if player hasn't been damaged for 2 seconds."""
	# Regenerate health every second
	if regen_cooldown - delta <= 0.0:
		GameStateTracker.update_health(stats.get("regen", 1))
		regen_cooldown = 1.0 + (delta - regen_cooldown)  # Regen once per second
	else:
		regen_cooldown -= delta

func die():
	hide() # Player disappears after dieing.
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func gain_experience(amount: float) -> void:
	"""Gain experience"""
	experience_changed.emit(amount)


#func _level_up() -> void:
	#"""Handle leveling up - increase all stats by a small amount."""
	#current_xp -= xp_to_level_up
	#current_level += 1
	#
	## Increase XP required for next level
	#xp_to_level_up *= xp_per_level_multiplier
	#
	## Increase all stats
	#strength += 0.1
	#speed += 2
	#regen += 1
	#attack_speed += 0.1
	#projectile_speed += 0.1
	#attack_range += 0.1
	#attack_size += 0.1
	#
	## Emit signals
	#experience_changed.emit(current_xp, xp_to_level_up, current_level)
	#GameStateTracker.update_experience(current_xp, xp_to_level_up, current_level)
	#level_up.emit()
