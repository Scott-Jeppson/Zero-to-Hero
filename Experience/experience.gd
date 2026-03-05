extends Area2D

@export var experience_value: float = 10.0

# Sprite textures for different experience amounts
var experience_sprites: Dictionary = {
	10.0: preload("res://art-assets/drops/exp/small.png"),  # Tier 1 (small)
	25.0: preload("res://art-assets/drops/exp/medium.png"),  # Tier 2 (medium)
	50.0: preload("res://art-assets/drops/exp/large.png"),  # Tier 3 (large)
	100.0: preload("res://art-assets/drops/exp/mega.png"),  # Tier 4 (huge)
}

var collected: bool = false


func _ready() -> void:
	add_to_group("experience")
	
	# Connect to area collision for player pickup
	area_entered.connect(_on_area_entered)
	
	# Set sprite based on experience value
	_update_sprite()
	
	# Update collision area based on experience value
	_update_collision()


func _process(delta: float) -> void:
	pass


func _update_sprite() -> void:
	"""Update the sprite based on experience value."""
	var sprite = $Sprite2D
	if sprite:
		# Find the appropriate sprite for this XP amount
		var closest_value = 10.0
		for xp_amount in experience_sprites.keys():
			if xp_amount <= experience_value:
				closest_value = xp_amount
		
		sprite.texture = experience_sprites.get(closest_value)


func _update_collision() -> void:
	"""Update collision area based on experience value."""
	var collision_shape = $CollisionShape2D
	if not collision_shape:
		return
	
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		# Scale radius based on experience value
		# Base radius of 10 at 10 XP, scales larger for higher values
		var base_radius = 10.0
		var radius_multiplier = sqrt(experience_value / 10.0)  # Square root for balanced scaling
		shape.radius = base_radius * radius_multiplier
	elif shape is RectangleShape2D:
		# For rectangle, scale both dimensions
		var base_size = Vector2(20.0, 20.0)
		var size_multiplier = sqrt(experience_value / 10.0)
		shape.size = base_size * size_multiplier


func _on_area_entered(area: Area2D) -> void:
	"""Called when an area enters this experience orb."""
	if collected:
		return
	
	if area.is_in_group("player"):
		collected = true
		area.gain_experience(experience_value)
		queue_free()
