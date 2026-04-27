extends "res://HUD/base_hud.gd"
## In-game HUD that displays player stats and timer

var health_label: Label
var xp_label: Label
var level_label: Label

func _ready() -> void:
	super._ready()
	
	health_label = $HealthLabel
	xp_label = $Xp
	level_label = $Level
	
	# Connect to GameStateTracker signals
	GameStateTracker.player_health_changed.connect(_on_health_changed)
	GameStateTracker.experience_changed.connect(_on_experience_changed)
	
	# Display initial values from tracker
	_on_health_changed(GameStateTracker.player_health, GameStateTracker.player_max_health)
	_on_experience_changed(GameStateTracker.player_current_xp, GameStateTracker.player_xp_to_level_up, GameStateTracker.player_current_level)
	
	$Clock/TimeKeeper.start()


func _process(_delta: float) -> void:
	# Health is now updated via signal, no need to update every frame
	pass


func update_xp_display(current_xp: float, max_xp: float, level: int) -> void:
	"""Update the XP and Level labels."""
	if xp_label:
		xp_label.text = "XP: %d / %d" % [int(current_xp), int(max_xp)]
	if level_label:
		level_label.text = "Level: %d" % level


func _on_health_changed(current_health: int, max_health: int) -> void:
	"""Called when player health changes."""
	if health_label:
		health_label.text = "Health: %d / %d" % [current_health, max_health]


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
