extends CharacterBody2D

# @export does the same thing as "serialized field" in Unity.
@export var movement_speed = 20.0
@export var hp = 15
@export var experience = 1
@export var enemy_damage = 1

# Hitbox Stuff
@onready var hitBox = $hitBox

# Variables for Knockback
@export var knockback_recovery = 3.5
var knockback = Vector2.ZERO

# @onready variables get a value after the nodes are loaded. Used to reference nodes.
# The get_tree() is one level above the world, the "root" so to speak.
# What this player variable is doing, is going to the top, then it's finding the first 
#     node that is found in the "player" group.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var animations = $AnimationPlayer

# Adding a hit sound for when the enemy it hit by an attack
@onready var sound_hit = $sound_hit

# Adding Loot
@onready var loot_base = get_tree().get_first_node_in_group("loot")
var exp_gem = preload("res://Objects/exp_gem.tscn")

# Explosion Animation Upon Death
var death_anim = preload("res://Enemies/explosion.tscn")

# Signal for preventing preventing a single piercing bullet from hitting more than once.
signal remove_from_array(object)

# Play the walking animation
# _ready() is a godot function, and runs once at the very beginning.
func _ready():
	animations.play("walk")
	hitBox.damage = enemy_damage

# Function to move the enemy towards you
# If you underscore delta, that means you want the function to _not_ use delta.
func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery) # Knockback
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()
	
	# Flip the enemy when it's changing direction
	# Note: There's a gap here of .1. This is so that the enemy doesn't flip a million times.
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false


func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else: # If the enemy doesn't die
		sound_hit.play()

# Function for when the enemy dies.
func death():
	emit_signal("remove_from_array", self) # Removes the enemy from the array
	
	# Playes the death animation
	var enemy_death = death_anim.instantiate() # Instantiate the animation
	enemy_death.scale = sprite.scale # Set the size to match the sprite of the enemy
	enemy_death.global_position = global_position # Set the position of where the animation is
	get_parent().call_deferred("add_child", enemy_death) # Animation plays on the parent of the enemy.
	
	# Spawn the Gem
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.exp_gain = experience
	loot_base.call_deferred("add_child",new_gem)
	
	queue_free() # Delete enemy from the game
