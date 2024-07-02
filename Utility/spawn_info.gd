extends Resource

class_name Spawn_info

# When the enemy spawns
@export var time_start:int
@export var time_end:int

# What enemy is meant to spawn
@export var enemy:Resource

# Number of enemies to spawn
@export var enemy_number:int

# Delay between spawns in seconds
@export var enemy_spawn_delay:int

# Tracks the delayed seconds
var spawn_delay_counter = 0
