extends "../mob_base.gd"

var movement_direction: Vector2


func _ready() -> void:
	# Set custom base stats for this enemy type
	base_health = 5.0
	base_speed = 500.0
	base_attack_power = 20.0	
	experience_drop_value = 25.0	
	# Call parent initialization
	super._ready()
	
	# Calculate movement direction once at spawn
	if not player:
		return
	
	# Step 4: Calculate direction to player
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# Step 5: Choose random distance between 100-200 pixels
	var random_distance = randf_range(100.0, 200.0)
	
	# Step 6: Get perpendicular direction
	var perpendicular = Vector2(-direction_to_player.y, direction_to_player.x)
	
	# Randomly choose left or right perpendicular (50/50 chance)
	if randf() > 0.5:
		perpendicular = -perpendicular
	
	# Calculate target location from player, perpendicular to direction
	var target_location = player.global_position + perpendicular * random_distance
	
	# Step 7: Calculate direction to target location
	movement_direction = (target_location - global_position).normalized()


func move() -> void:
	"""Move in the calculated direction (set only at spawn)."""
		# Check distance from player
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > 2000:
			queue_free()
			return
	
	linear_velocity = movement_direction * current_speed
