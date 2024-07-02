extends Area2D

@export var exp_gain = 1

var spr_green = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red = preload("res://Textures/Items/Gems/Gem_red.png")

var target = null # What our gem moves into
var speed = -1 # The speed at which the gem attracts to you

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $sound_collected

func _ready():
	# If statement that sets the color of the gem based on the amount of exp it gives.
	if exp_gain < 5:
		return
	elif exp_gain < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red
		
func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta
		
func collect():
	sound.play()
	collision.call_deferred("set", "disabled", true) # We could queue_free it, but that will cut off the sound.
	sprite.visible = false
	return exp_gain

# This function will allow the sound to play, and once it's done, the object is freed.
func _on_sound_collected_finished():
	queue_free()
