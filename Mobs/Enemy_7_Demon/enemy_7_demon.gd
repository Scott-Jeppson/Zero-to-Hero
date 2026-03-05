extends "../mob_base.gd"


func _ready() -> void:
	# Set custom base stats for this enemy type
	base_health = 50.0
	base_speed = 150.0
	base_attack_power = 20.0
	experience_drop_value = 50.0	
	# Call parent initialization
	super._ready()
