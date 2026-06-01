# ExAutoRogue
An Addon for 1.12.1 / 1.18.1 (TurtleWoW) for automatically managing a Rogue's combat rotation to maintain maximum uptime on Slice and Dice while efficiently spending combo points. This addon dynamically reads your spellbook to adapt to your level and talent build, making it perfect for custom servers and unique ability paths.

Inspired by Excinerus' ExAutoCSHS addon, ExAutoRogue relies on CombatLog entries to detect Parries for instant Riposte casts, completely bypassing the need to have it on your action bar or handle macro race conditions.

Additionally, it features smart target-classification detection to automatically manage major cooldowns and debuffs like Expose Armor based on whether you are fighting normal mobs or Elites/Bosses.

# Important Setup Requirement: 

## ⚠️ Critical Setup Requirement
To allow the addon to smoothly manage auto-attacks without toggling them off when spamming, you must place the standard Attack icon (found in the General tab of your Spellbook) anywhere on your action bars. The addon scans all 172 possible action slots to safely trigger weapon swings.

Note: If you use the SuperCleveRoidMacros (SCRM) addon, this is not required. You can simply add /startattack to the top of your macro.

# Usage & Command Arguments
Create a standard in-game macro with the following command:

`/AutoRogue [evis4/evis5] [hemo] [cds] [autocd] [expose] [nosnd]`


## 🧠 Smart Auto-Detection Features
ExAutoRogue scans your spellbook automatically. It will gracefully ignore abilities you haven't learned yet (no need to manually bypass Slice and Dice while under level 10). It also automatically detects custom abilities like Envenom and Noxious Assault, smoothly weaving them into your priority rotation if you have them trained, and tracking Deadly Poison stacks to ensure maximum damage.

## ⚙️ Configuration Options

- `evis4` - Casts Eviscerate at 4+ combo points [Active Default].
- `evis5` - Waits to cast Eviscerate until you have exactly 5 combo points.
- `hemo` - Uses Hemorrhage as your primary combo point builder [Default is Sinister Strike].
- `cds` - Pops Adrenaline Rush and Blade Flurry on cooldown regardless of target [Disabled by default].
- `autocd` - Only pops Adrenaline Rush and Blade Flurry if the target is classified as an Elite, Rare Elite, or World Boss [Disabled by default].
- `expose` - Attempts to apply Expose Armor at 5 combo points if the target is an Elite/Boss and does not already have the debuff [Disabled by default].
- `nosnd` - Completely forces the addon to ignore Slice and Dice, useful if you want a pure Eviscerate/Envenom dump build.

# Example: 
# The Standard Leveling Setup
`/AutoRogue`

Functions with all default settings. It ensures auto-attack is on, instantly casts Riposte if you parry, smartly refreshes Slice and Dice when it drops, dumps remaining points into Eviscerate at 4+ CP, and builds with your primary strike.

# The "Smart Boss" Setup
`/AutoRogue evis5 autocd expose`

On a normal mob, it functions like a standard rotation. However, when you target an Elite or Boss, it intelligently pops Adrenaline Rush and Blade Flurry, builds 5 combo points to cast Expose Armor, and then proceeds to spend future 5-point combos on Eviscerate (or Envenom).

# The Subtlety Setup
`/AutoRogue hemo evis5`

Replaces Sinister Strike with Hemorrhage as the combo point builder and waits for 5 full combo points before casting your finishing moves.
