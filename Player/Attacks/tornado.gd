extends Area2D

# General Tornado Stats
var level = 1
var hp = 9999
var speed = 100.0
var damage = 5
var attack_size = 1.0
var knockback_amount = 100

# Determines direction of the attack
var last_movement = Vector2.ZERO
var angle = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	match level:
		1: 
			hp = 9999
			speed = 100.0
			damage = 5
			attack_size = 1.0 * (1 + player.spell_size)
			knockback_amount = 100
		2: # Shoots another tornado
			hp = 9999
			speed = 100.0
			damage = 5
			attack_size = 1.0 * (1 + player.spell_size)
			knockback_amount = 100
		3: # Reduce the cooldown
			hp = 9999
			speed = 100.0
			damage = 5
			attack_size = 1.0 * (1 + player.spell_size)
			knockback_amount = 100
		4: # Increase knockback amount
			hp = 9999
			speed = 100.0
			damage = 5
			attack_size = 1.0 * (1 + player.spell_size)
			knockback_amount = 125
	
	# Process Attack Movement
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1, -0.25), last_movement.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * 500
		Vector2.RIGHT, Vector2.LEFT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1, -0.25)) * 500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * 500
		Vector2(1,1), Vector2(-1,-1), Vector2(1, -1), Vector2(-1, 1): # Diagonals
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0,0.75)) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0,0.75), last_movement.y) * 500
			
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed = speed
	speed = speed / 5
	initial_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initial_tween.play()
	
	var tween = create_tween()
	var set_angle = randi_range(0,1) # Will return either 1 or 0
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
	else:
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
	tween.play()
	
func _physics_process(delta):
	position += angle * speed * delta


func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
