extends "../mob_base.gd"


func _ready() -> void:
	# Set custom base stats for this enemy type
	base_health = 10.0
	base_speed = 100.0
	base_attack_power = 5.0
	experience_drop_value = 10.0
	
	# Call parent initialization
	super._ready()
