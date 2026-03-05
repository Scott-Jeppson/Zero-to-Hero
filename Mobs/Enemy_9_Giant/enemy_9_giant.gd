extends "../mob_base.gd"


func _ready() -> void:
	# Set custom base stats for this enemy type
	base_health = 100.0
	base_speed = 30.0
	base_attack_power = 100.0	
	experience_drop_value = 100.0	
	# Call parent initialization
	super._ready()
