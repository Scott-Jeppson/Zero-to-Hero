extends Node2D

var spawn_difficulty_timer: float = 0.0  # Tracks time for spawn rate increase
var game_paused: bool = true

# Mob spawning configuration with weights (0 = never spawn initially)
var mob_weights: Dictionary = {
	"res://Mobs/Enemy_1_Base/enemy_1_base.tscn":9.0,
	"res://Mobs/Enemy_2_Bulky/enemy_2_bulky.tscn": 8.0,
	"res://Mobs/Enemy_3_Attacker/enemy_3_attacker.tscn": 7.0,
	"res://Mobs/Enemy_4_PasserBy/enemy_4_passer_by.tscn": 6.0,
	"res://Mobs/Enemy_5_Speedy/enemy_5_speedy.tscn": 5.0,
	"res://Mobs/Enemy_6_Ranged/enemy_6_ranged.tscn": 4.0,
	"res://Mobs/Enemy_7_Demon/enemy_7_demon.tscn": 3.0,
	"res://Mobs/Enemy_8_Double/enemy_8_double.tscn": 2.0,
	"res://Mobs/Enemy_9_Giant/enemy_9_giant.tscn": 1.0,
	"": 6.0,  # No spawn
}

# Spawn locations that move along the path
var spawn_locations: Array = []

# Speed for each spawn location along the path
var spawn_location_speeds: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStateTracker.state_changed.connect(_on_game_state_changed)
	# Initialize spawn locations after scene tree is ready
	spawn_locations = [
		$Player/MobSpawn/MobSpawnLocation,
		$Player/MobSpawn/MobSpawnLocation2,
		$Player/MobSpawn/MobSpawnLocation3,
		$Player/MobSpawn/MobSpawnLocation4,
		$Player/MobSpawn/MobSpawnLocation5,
	]
	
	$Player.position = $StartPosition.position
	
	# Set initial progress for each spawn location
	for spawn_location in spawn_locations:
		if spawn_location is PathFollow2D:
			spawn_location.progress = 0.0
	
	$Player.add_attack("res://Attacks/Player Attacks/minus.tscn", 1.0)
	$Mob_Spawner.start()
	$Player/InGameHUD.visible = false
	
	GameStateTracker.change_state("Main Menu")

func _on_game_state_changed(new_state: String) -> void:
	match new_state:
		"Main Menu":
			$Player/InGameHUD.visible = false
			$MainMenuHUD.visible = true
		"Playing":
			$MainMenuHUD.visible = false
			$Player/InGameHUD.visible = true
			new_game()
			# Ensure camera is centered on player
			$Player/Camera2D.global_position = $Player.global_position
		"Paused":
			game_paused = true
			get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Stop spawning if player is dead
	if game_paused:
		return
	# Move spawn locations along the path
	for spawn_location in spawn_locations:
		if not is_instance_valid(spawn_location):
			continue
		if spawn_location is PathFollow2D:
			spawn_location.progress_ratio = randf(); #Randomize position around player
	
	# Gradually increase spawn frequency
	spawn_difficulty_timer += delta
	
	# Decrease timer wait time every 10 seconds
	if spawn_difficulty_timer >= 5.0:
		var current_wait_time = $Mob_Spawner.wait_time
		
		# Only decrease if above 1 second minimum
		if current_wait_time > 1.0:
			$Mob_Spawner.wait_time = max(1.0, current_wait_time - 0.1)
		
		spawn_difficulty_timer = 0.0

func new_game():
	game_paused = false
	$Player.start($StartPosition.position)


func _on_mob_spawner_timeout() -> void:
	"""Spawn a random mob at each spawn location based on independent weighted selection."""
	if game_paused:
		return
	for spawn_location in spawn_locations:
		var selected_mob_path = _select_weighted_mob()
		if selected_mob_path != "":  # Only spawn if not the "no spawn" option
			_spawn_mob(selected_mob_path, spawn_location)


func _select_weighted_mob() -> String:
	"""Select a random mob by creating a weighted array."""
	# Build an array where each enemy appears N times based on its weight
	var weighted_array: Array = []
	
	for mob_path in mob_weights.keys():
		var weight = int(mob_weights[mob_path])
		for i in range(weight):
			weighted_array.append(mob_path)
	
	# If array is empty, return empty string
	if weighted_array.is_empty():
		return ""
	
	# Pick a random element from the weighted array
	var selected = weighted_array[randi() % weighted_array.size()]
	return selected


func _spawn_mob(mob_scene_path: String, spawn_location: Node2D) -> void:
	"""Spawn a specific mob at the given spawn location."""
	if not is_instance_valid(spawn_location):
		return
	
	var mob_scene = load(mob_scene_path)
	if not mob_scene:
		return
	
	var mob = mob_scene.instantiate()
	
	# Spawn at the specified location
	mob.global_position = spawn_location.global_position
	
	# Add to scene
	add_child(mob)


func _on_player_died() -> void:
	"""Stop spawning when the player dies."""
	_pause_game()
	
	
func _pause_game() -> void:
	"""Pauses the game"""
	game_paused = true
	$Mob_Spawner.stop()
	$Player/InGameHUD/Clock/TimeKeeper.stop()
	
func _resume_game() -> void:
	"Resumes the game from pause"
	game_paused = false
