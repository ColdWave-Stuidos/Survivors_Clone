extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $disableTimer

signal hurt(damage, angle, knockback)

var hit_once_arr = []

func _on_area_entered(area):
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: # Cooldown
					collision.call_deferred("set", "disabled", true)
					disableTimer.start()
				1: # Hit Once
					if hit_once_arr.has(area) == false:
						hit_once_arr.append(area) # If the enemy has not been hit by the attack, the attack is added to the array. This prevents piercing attacks from hitting multiple times.
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array", Callable(self, "remove_from_list")):
								area.connect("remove_from_array", Callable(self, "remove_from_list"))
					else:
						return # breaks out of the function
				2: # Disable Hitbox
					if area.has_method("tempDisable"):
						area.tempDisable()
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback = 1
			
			# Does the attack have the angle property?
			if not area.get("angle") == null:
				angle = area.angle
				
			# Does the attack have the knockback amount property?
			if not area.get("knockback_amount") == null:
				knockback = area.knockback_amount
			
			emit_signal("hurt", damage, angle, knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false)

func remove_from_list(object):
	if hit_once_arr.has(object):
		hit_once_arr.erase(object)
