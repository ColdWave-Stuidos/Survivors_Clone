extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("explosion_animation") # Play the animation

# When the animation is done, the explosion disappears.
func _on_animation_player_animation_finished(anim_name):
	queue_free()
