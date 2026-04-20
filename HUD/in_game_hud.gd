extends "res://HUD/base_hud.gd"
## In-game HUD that displays player stats and timer

var player: Node2D
var health_label: Label
var xp_label: Label
var level_label: Label

func _ready() -> void:
	super._ready()
	
	# Get references to the player and labels
	player = get_tree().get_first_node_in_group("player")
	if not player:
		# Fallback: try "players" group
		player = get_tree().get_first_node_in_group("players")
	
	health_label = $HealthLabel
	xp_label = $Xp
	level_label = $Level
	
	# Connect to player signals
	if player:
		player.died.connect(_on_player_died)
		player.experience_changed.connect(_on_experience_changed)
		# Display initial values
		update_health_display()
		update_xp_display(player.current_xp, player.xp_to_level_up, player.current_level)
	
	$Clock/TimeKeeper.start()


func _process(_delta: float) -> void:
	# Update health display every frame
	if player:
		update_health_display()


func update_health_display() -> void:
	"""Update the health label with player's current and max hit points."""
	if player and health_label:
		health_label.text = "Health: %d / %d" % [player.hit_points, player.max_hit_points]


func update_xp_display(current_xp: float, max_xp: float, level: int) -> void:
	"""Update the XP and Level labels."""
	if xp_label:
		xp_label.text = "XP: %d / %d" % [int(current_xp), int(max_xp)]
	if level_label:
		level_label.text = "Level: %d" % level


func _on_player_died() -> void:
	"""Called when the player dies."""
	health_label.text = "Health: 0"


func _on_experience_changed(current_xp: float, max_xp: float, level: int) -> void:
	"""Called when player gains experience or levels up."""
	update_xp_display(current_xp, max_xp, level)


func _on_time_keeper_timeout() -> void:
	"""Increase the clock by 1 second."""
	var clock_text = $Clock.text
	
	# Parse current time (format: M:SS)
	var time_parts = clock_text.split(":")
	var minutes = int(time_parts[0])
	var seconds = int(time_parts[1])
	
	# Increment by 1 second
	seconds += 1
	
	# Handle overflow when seconds reach 60
	if seconds >= 60:
		seconds = 0
		minutes += 1
	
	# Update the clock label with formatted time
	$Clock.text = "%d:%02d" % [minutes, seconds]
