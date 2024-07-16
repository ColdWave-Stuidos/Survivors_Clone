extends Node2D

@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

@export var time = 0

signal changetime(time)

func _ready():
	connect("changetime", Callable(player, "change_time"))

# Timer is run every second.
func _on_timer_timeout():
	# Add one second to the timer
	time += 1 
	
	# Go through the enemy_spawns array
	var enemy_spawns = spawns
	for i in enemy_spawns:
		# Are we between the start and stop time? If so, start spawning.
		if time >= i.time_start and time <= i.time_end:
			
			# Before spawns start, is there a delay?
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1 # increase the counter for next time
			else:
				i.spawn_delay_counter = 0 # Reset the delay counter
				var new_enemy = i.enemy # Load in the enemy
				var counter = 0
				
				# Spawn in the number of enemies of the enemy num value.
				while counter < i.enemy_number: 
					# Create a new instance of our enemy
					var enemy_spawn = new_enemy.instantiate() # Create instance of packed scene
					enemy_spawn.global_position = get_random_position() # Get a random position
					
					# Add enemy as a child until we get the number of enemies we want to spawn.
					add_child(enemy_spawn)
					counter += 1
					
	emit_signal("changetime", time)

func get_random_position():
	# This rectangle is the current view the player sees, with some extra range on it.
	var viewport_rect = get_viewport_rect().size * randf_range(1.1, 1.4)
	
	# Get a postiion for where the enemy can spawn
	var top_left = Vector2(player.global_position.x - viewport_rect.x/2, player.global_position.y - viewport_rect.y/2)
	var top_right = Vector2(player.global_position.x + viewport_rect.x/2, player.global_position.y - viewport_rect.y/2)
	var bottom_left = Vector2(player.global_position.x - viewport_rect.x/2, player.global_position.y + viewport_rect.y/2)
	var bottom_right = Vector2(player.global_position.x + viewport_rect.x/2, player.global_position.y + viewport_rect.y/2)
	
	# Get a random side the enemy will spawn on
	var pos_side = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	# Based on the random side that is chosen, this determines where it will spawn
	match pos_side: 
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right": 
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left

	# Returns the position of the new spawn.
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)
