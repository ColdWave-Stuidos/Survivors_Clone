# Vampire Survivors Clone in Godot

I have been following a tutorial series on YouTube by [Branno](https://www.youtube.com/@BrannoDev) where he shows you how to create a [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) clone. 

I am using his tutorial series (found [here](https://www.youtube.com/playlist?list=PLtosjGHWDab682nfZ1f6JSQ1cjap7Ieeb)) to get a feel for Godot Engine and Godot 4. I have tried to use Godot in the past, but now I am really trying to make an effort to learn it. 

## What's been implemented from the tutorial
- Basic Animations
  - The player will animate only while walking
  - The enemies are in a constant state of animation
- Player Movement
- Basic Enemies
  - The enemies spawn in from just outside the screen.
  - The enemies will constnatly walk towards the player.
  - These basic enemies deal 1 hp worth of damage as they bump into the player.
- Basic Attacks
- Leveling Up and choosing upgrades
- Added a health bar and the player can now visually lose health.
- Added a timer to show how long you have been in the game.
- Added a GUI for what items the player currently has collected.
- Added additional enemies:
	- Kobold (Strong)
	- Cyclops
	- Juggernaut
	- Amoeba (This game's version of the Reaper)

### Attack List
- Ice Spear
- Tornado
- Javelin

### Item List
- Food (Heals the player)
- Ring (Adds an additional bullet per shot)
- Tome (Makes spells larger)
- Armor (Grants armor)
- Speed Shoes (Player moves faster)
- Scroll (Decreases spell cooldown)

## Ideas I want to Add after the tutorial
- [ ] Ice Spear explodes into little shards on death
- [ ] Javelin returns to the player before firing again
 - Currently, the javelin will just bounce all over the map. If you move around the map too much, the javelins will eventually be too far away to hit anything.
- [ ] Add a new attack of "Water" (thinking like a little tidal wave)
- [ ] An attack: "Bees"
