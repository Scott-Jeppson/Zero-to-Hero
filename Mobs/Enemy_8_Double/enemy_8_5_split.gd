extends "../mob_base.gd"


func _ready() -> void:
	# Set custom base stats for this split enemy type
	# Half health and attack, but double speed of regular Enemy 8
	base_health = 15.0  # Half of 30
	base_speed = 180.0  # Double of 90
	base_attack_power = 4.5  # Half of 9
	experience_drop_value = 50.0  # Large XP
	
	# Call parent initialization
	super._ready()
