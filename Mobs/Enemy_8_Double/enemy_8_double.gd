extends "../mob_base.gd"


func _ready() -> void:
	# Set custom base stats for this enemy type
	base_health = 30.0
	base_speed = 90.0
	base_attack_power = 9.0
	experience_drop_value = 0.0  # Don't drop XP, splits will instead
	
	# Call parent initialization
	super._ready()


func die() -> void:
	"""When Enemy 8 dies, spawn two split enemies instead of dropping XP."""
	var split_scene = load("res://Mobs/Enemy_8_Double/enemy_8_5_split.tscn")
	if not split_scene:
		return
	
	# Spawn two split enemies side by side
	var offset_distance = 40.0
	var positions = [
		global_position + Vector2(-offset_distance, 0),  # Left
		global_position + Vector2(offset_distance, 0)   # Right
	]
	
	for pos in positions:
		var split_enemy = split_scene.instantiate()
		split_enemy.global_position = pos
		get_parent().add_child(split_enemy)
	
	# Remove this enemy
	queue_free()
