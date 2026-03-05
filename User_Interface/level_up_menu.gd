extends CanvasLayer

var player: Node2D
var remaining_increases: int = 0
var stats: Dictionary;

# UI Label references
var remaining_label: Label
var health: Label
var strength: Label
var speed: Label
var regen: Label
var attack_speed: Label
var attack_range: Label
var attack_size: Label


func _ready() -> void:
	# Hide menu initially (only show on level up)
	visible = false
	
	# Defer player connection to next frame so player has time to add itself to group
	await get_tree().process_frame
	
	# Find the player
	player = get_tree().get_first_node_in_group("player")
	
	# Connect to player's level up signal
	if player and player.has_signal("level_up"):
		player.level_up.connect(_on_level_up)
	
	# Get reference to remaining label
	remaining_label = $PanelContainer/UIContainer/RemainingLabel
	health = $PanelContainer/UIContainer/HealthContainer/Health
	strength = $PanelContainer/UIContainer/StrengthContainer/Strength
	speed = $PanelContainer/UIContainer/SpeedContainer/Speed
	regen = $PanelContainer/UIContainer/RegenContainer/Regen
	attack_speed = $PanelContainer/UIContainer/AttackSpeedContainer/AttackSpeed
	attack_range = $PanelContainer/UIContainer/AttackRangeContainer/AttackRange
	attack_size = $PanelContainer/UIContainer/AttackSizeContainer/AttackSize


func _on_health_button_pressed() -> void:
	print("increase health button pressed")
	if visible and remaining_increases > 0:
		stats["hit_points"] += 10
		remaining_increases -= 1
		_update_display()


func _on_strength_button_pressed() -> void:
	if visible and remaining_increases > 0:
		stats["strength"] += 5
		remaining_increases -= 1
		_update_display()


func _on_speed_button_pressed() -> void:
	if visible and remaining_increases > 0:
		stats["speed"] += 5
		remaining_increases -= 1
		_update_display()


func _on_regen_button_pressed() -> void:
	if visible and remaining_increases > 0:
		stats["regen"] += 1
		remaining_increases -= 1
		_update_display()


func _on_attack_speed_button_pressed() -> void:
	if visible and remaining_increases > 0:
		stats["attack_speed"] += 0.1
		remaining_increases -= 1
		_update_display()


func _on_attack_range_button_pressed() -> void:
	if visible and remaining_increases > 0:
		stats["attack_range"] += 0.1
		remaining_increases -= 1
		_update_display()


func _on_attack_size_button_pressed() -> void:
	if visible and remaining_increases > 0:
		stats["attack_size"] += 0.1
		remaining_increases -= 1
		_update_display()


func _on_health_decrease_button_pressed() -> void:
	if visible and stats["hit_points"] > 0:
		stats["hit_points"] -= 10
		remaining_increases += 1
		_update_display()


func _on_strength_decrease_button_pressed() -> void:
	if visible and stats["strength"] > 0:
		stats["strength"] -= 5
		remaining_increases += 1
		_update_display()


func _on_speed_decrease_button_pressed() -> void:
	if visible and stats["speed"] > 0:
		stats["speed"] -= 5
		remaining_increases += 1
		_update_display()


func _on_regen_decrease_button_pressed() -> void:
	if visible and stats["regen"] > 0:
		stats["regen"] -= 1
		remaining_increases += 1
		_update_display()


func _on_attack_speed_decrease_button_pressed() -> void:
	if visible and stats["attack_speed"] > 0:
		stats["attack_speed"] -= 0.1
		remaining_increases += 1
		_update_display()


func _on_attack_range_decrease_button_pressed() -> void:
	if visible and stats["attack_range"] > 0:
		stats["attack_range"] -= 0.1
		remaining_increases += 1
		_update_display()


func _on_attack_size_decrease_button_pressed() -> void:
	if visible and stats["attack_size"] > 0:
		stats["attack_size"] -= 0.1
		remaining_increases += 1
		_update_display()

func _on_level_up() -> void:
	"""Show the level up menu when player levels up."""
	# Track stat changes for this level up
	stats = {
		"hit_points": player.max_hit_points,
		"strength": player.strength,
		"speed": player.speed,
		"regen": player.regen,
		"attack_speed": player.attack_speed,
		"attack_range": player.attack_range,
		"attack_size": player.attack_size,
	}
	remaining_increases += 3
	
	# Show menu and pause game
	visible = true
	get_tree().paused = true
	_update_display()

func _on_confirm() -> void:
	"""Apply stat changes and close the menu."""
	if not player:
		return
	
	# Apply all stat changes
	player.hit_points = stats["hit_points"]
	player.max_hit_points = stats["hit_points"]
	player.strength = stats["strength"]
	player.speed = stats["speed"]
	player.regen = stats["regen"]
	player.attack_speed = stats["attack_speed"]
	player.attack_range = stats["attack_range"]
	player.attack_size = stats["attack_size"]
	
	# Close menu and resume game
	visible = false
	get_tree().paused = false


func _update_display() -> void:
	print("updating display")
	"""Update the remaining increases label and stat displays."""
	if remaining_label:
		remaining_label.text = "Remaining Increases: %d" % remaining_increases
	
	# Update individual stat displays
	health.text = "Health: \n" + str(stats["hit_points"])
	strength.text = "Strength: \n" + str(stats["strength"])
	speed.text = "Speed: \n" + str(stats["speed"])
	regen.text = "Regen: \n" + str(stats["regen"])
	attack_speed.text = "Attack Speed: \n" + str(stats["attack_speed"])
	attack_range.text = "Attack Range: \n" + str(stats["attack_range"])
	attack_size.text = "Attack Size: \n" + str(stats["attack_size"])
