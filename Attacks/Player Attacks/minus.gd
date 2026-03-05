extends "./attack_base.gd"

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	base_damage = 10.0
	base_range = 1000.0
	base_speed = 300.0
	base_size_multiplier = 0.5
	base_attack_cooldown = 1.0
	destroy_on_hit = true
	
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)


func move(delta: float) -> void:
	"""Move the attack in the set direction."""
	
	# Rotate to face the direction of movement
	rotation = direction.angle()
	
	position += direction * current_speed * delta
	distance_traveled += current_speed * delta
	
