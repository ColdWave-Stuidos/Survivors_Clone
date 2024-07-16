# Vampire Survivors Clone in Godot

I have been following a tutorial series on YouTube by [Branno](https://www.youtube.com/@BrannoDev) where he shows you how to create a [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) clone. 

I am using his tutorial series (found [here](https://www.youtube.com/playlist?list=PLtosjGHWDab682nfZ1f6JSQ1cjap7Ieeb)) to get a feel for Godot Engine and Godot 4. I have tried to use Godot in the past, but now I am really trying to make an effort to learn it. 

## What's been implemented from the tutorial
- The GUI
  - Health bar
  - Experience bar
  - Game timer
  - Level Up Menu
  - Icons for what items the player has collected
  - Win/Lose Screen 
  - Main Menu
- Basic Animations
  - The player will animate only while walking
  - The enemies are in a constant state of animation
- Player Movement
- Basic Enemies
  - The enemies spawn in from just outside the screen.
  - The enemies will constnatly walk towards the player.
  - These basic enemies deal 1 hp worth of damage as they bump into the player.
- Basic Attacks
  - Ice Spear
  - Tornado
  - Javelin
- Basic Items
  - Food (Heals the Player)
  - Ring (Adds an additional bullet per shot)
  - Tome (Makes spells larger)
  - Armor (Grants Armor)
  - Speed Shoes (Player moves faster)
  - Scroll (Decreases spell cooldown)
- Added additional enemies:
	- Kobold (Strong)
	- Cyclops
	- Juggernaut
	- Amoeba (This game's version of the Reaper)


## Ideas I want to Add after the tutorial
- New attacks
  - [ ] "Water"
  - [ ] "Bees"
  - Attack Upgrades
	- [ ] Ice spear shatters upon projectile death
	- [ ] Javelin returns to player before launching again
- New Items
  - [ ] "Magnet"
- New Characters
  - [ ] "Frosty"
- Miscellaneous
  - [ ] Pause menu
  - [ ] Enemy organization
	- Currently, if I need to make a change to all enemies, I'd have to do it individually instead of changing one thing.
	- I should be able to create a collective scene. The scene has all the same children (except collision shape). In each enemy's script, you can add `class_name EnemyBody` (where `EnemyBody` is the name of the collective scene.). 
	- Change the `@onready var` for all of the ones that would need to be changed at once to reflect the change: something like `$EnemyBase/Hitbox`. 
	- The signals would then need to be conencted via code.
	- In the enemy.gd script, you would add `extends EnemyBody` at the top.
- Optimizations
  - [ ] Circle collision shapes can be more optimal than capsule
  - [ ] Set a limit to the number of enemies that can spawn at one time (may require a backlog of enemies so that you don't miss any of the spawns you were suppsoed to spawn.)
  - [ ] Make an enemy invisible if it is off-screen.
