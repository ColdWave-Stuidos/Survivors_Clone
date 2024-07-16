extends CharacterBody2D

# Player Variables
var movement_speed = 50.0
var hp = 80
var maxhp = 80
var last_movement = Vector2.UP
var experience = 0
var exp_level = 1 # Current Player Level
var collected_exp = 0 # How much player has collected

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("walkTimer")

# GUI
@onready var expBar = get_node("%ExpBar")
@onready var level_label = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var soundLevelUp = get_node("%sound_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")
var time = 0

# Death Screen
@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")

# Attacks
var icespear = preload("res://Player/Attacks/ice_spear.tscn")
var tornado = preload("res://Player/Attacks/tornado.tscn")
var javelin = preload("res://Player/Attacks/javelin.tscn")

# Attack Nodes
@onready var icespearTimer = get_node("%IceSpearTimer")
@onready var icespearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

# Upgrade Variables
var collected_upgrades = [] # The upgrades currently equiped to the player.
var upgrade_options = [] # The three upgrades presented to the player when leveling up.
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0

# Ice Spear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.5
var icespear_level = 0

# Tornado
var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 3
var tornado_level = 0

# Javelin
var javelin_ammo = 0
var javelin_level = 0

# To hold the enemies that are close to the player.
var close_enemies = [] 


# Load this up when the game starts
func _ready():
	upgrade_character("icespear1") # Starting weapon
	attack()
	set_expBar(experience, calculate_exp_cap())
	_on_hurt_box_hurt(0,0,0) # Sets the HP Bar at the start. 0s so player takes no damage.

# Function for the game loop
func _physics_process(delta):
	movement()

# Movement Function
func movement():
	# The .get_action_strength("right") will return 1 of you are pressing D, 0 if not.
	var x_move = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_move = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# This is just a variable that gives a direction.
	var move = Vector2(x_move, y_move)
	
	# If statement to flip the sprite if player is moving left / right
	if move.x > 0:
		sprite.flip_h = true
	elif move.x < 0:
		sprite.flip_h = false
		
	# Playing the walking animaition
	if move != Vector2.ZERO:
		last_movement = move
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	# Set the player's velocity, where is the movement directed to.
	velocity = move.normalized() * movement_speed
	
	# move_and_slide() is a godot function that will let the character move.
	move_and_slide()

# If the player has the attack, then they can use it.
func attack():
	if icespear_level > 0:
		icespearTimer.wait_time = icespear_attackspeed * (1-spell_cooldown)
		if icespearTimer.is_stopped():
			icespearTimer.start()
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1-spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()

# Funciton to hurt the player upon contact.
func _on_hurt_box_hurt(damage, _angle, _knockback): # The function still needs the arguments, but we don't want to knock back the player
	hp -= clamp(damage - armor, 1.0, 999) # This guarantees you will always take 1 damage.
	healthBar.max_value = maxhp
	healthBar.value = hp
	
	if hp <= 0:
		death()

# Think of this as "loading the ammo"
func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo + additional_attacks
	icespearAttackTimer.start()

# Think of this as shooting a machine gun.
func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = icespear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			icespearAttackTimer.start()
		else:
			icespearAttackTimer.stop()


# Tornado Timeouts
func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo + additional_attacks
	tornadoAttackTimer.start()


func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement # The only difference between ice spear
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()


func get_random_target():
	if close_enemies.size() > 0:
		return close_enemies.pick_random().global_position
	else: 
		return Vector2.LEFT

func _on_enemy_detection_area_body_entered(body):
	if not close_enemies.has(body):
		close_enemies.append(body)

func _on_enemy_detection_area_body_exited(body):
	if close_enemies.has(body):
		close_enemies.erase(body)

func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = javelin_ammo - get_javelin_total  + additional_attacks
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	# Update Javelin Stats
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_exp(gem_exp)
		

func calculate_exp(gem_exp):
	var exp_required = calculate_exp_cap()
	collected_exp += gem_exp
	if experience + collected_exp >= exp_required: # Level Up
		collected_exp -= exp_required - experience
		exp_level += 1 
		experience = 0
		exp_required = calculate_exp_cap()
		level_up()
		
	else: 
		experience += collected_exp
		collected_exp = 0
		
	set_expBar(experience, exp_required)

func calculate_exp_cap():
	var exp_cap = exp_level
	if exp_level < 20:
		exp_cap = exp_level * 5
	elif exp_level < 40:
		exp_cap = ((exp_level - 19) * 8) + 95
	else:
		exp_cap = ((exp_level - 39) * 12) + 255
	return exp_cap

func set_expBar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value
	
func level_up():
	soundLevelUp.play()
	level_label.text = str("Level: ", exp_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
		
	get_tree().paused = true
	
func upgrade_character(upgrade):
	# Give functionality to the upgrades
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp) # stops healing when you hit the max HP
	
	# Update the GUI
	adjust_gui_collection(upgrade)
	
	# Refresh your attacks
	attack()
	
	# Get all the children in the upgrade menu and delete them.
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_exp(0) # You call it again without adding any exp to account for exp overflow.

func get_random_item():
	var dbList = [] # Variable to hold all currently available upgrades.
	
	# For loop to go through list of upgrades in UpgradeDB, and add any that we meet the prereqs for. It will not re-add any that we already have, or ones that are already in the list.
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: # Find the upgrades already collected
			pass
		elif i in upgrade_options: # If the upgrade is already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": # Don't pick items
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: # Check for prereqs
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades: # Skip if we do not have the prereqs
					to_add = false
			
			if to_add:	
				dbList.append(i)
		else:
			dbList.append(i)
	
	# See if anything gets added to the dbList variable
	if dbList.size() > 0:
		var randomItem = dbList.pick_random()
		upgrade_options.append(randomItem)
		return randomItem
	else:
		# If there are no more applicable upgrades, it will give us food, since that's the default.
		return null
		
# Function for the game timer
func change_time(argtime = 0):
	time = argtime
	var get_minutes = int(time/60.0)
	var get_seconds = time % 60
	if get_minutes < 10:
		get_minutes = str(0, get_minutes)
	if get_seconds < 10:
		get_seconds = str(0, get_seconds)
	lblTimer.text = str(get_minutes,":",get_seconds)

func adjust_gui_collection(upgrade):
	var get_upgraded_displaynames = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displaynames in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)


func death():
	deathPanel.visible = true
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
	if time >= 300:
		lblResult.text = "You Win!"
		sndVictory.play()
	else:
		lblResult.text = "You Lose!"
		sndLose.play()
