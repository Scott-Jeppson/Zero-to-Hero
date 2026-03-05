extends "../mob_base.gd"


func _ready() -> void:
	# Set custom base stats for this enemy type
	base_health = 7.0
	base_speed = 110.0
	base_attack_power = 10.0	
	experience_drop_value = 10.0	
	# Call parent initialization
	super._ready()
