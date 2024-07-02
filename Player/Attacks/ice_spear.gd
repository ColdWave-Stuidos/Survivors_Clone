extends Area2D

# Variables for the ice spear itself
var level = 1
var hp = 1
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

# Variables to get the target and the angle to shoot at
var target = Vector2.ZERO
var angle = Vector2.ZERO

# Get the player character
@onready var player = get_tree().get_first_node_in_group("player")

# Signal for preventing preventing a single piercing bullet from hitting more than once.
signal remove_from_array(object)

func _ready():
	# Whatever the target, the angle will be directed to it.
	angle = global_position.direction_to(target) 
	
	# Sets the rotation. This is done entirely in radians.
	rotation = angle.angle() + deg_to_rad(135)
	
	match level:
		1: # SHoots one ice spear
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		2: # Shoots an additional ice spear
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		3: # Adds 1 pierce to the ice spear and +3 damage
			hp = 2
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		4: # An additional 2 ice spears
			hp = 2
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1) * attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

# This happens every physics frame
func _physics_process(delta):
	position += angle * speed * delta

# When the ice spear hits the enemy, it reduces its HP by one and disappears
func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
