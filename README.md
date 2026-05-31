# ExAutoRogue
An Addon for TurtleWoW for automatically managing a Rogue's combat rotation to maintain maximum uptime on Slice and Dice while efficiently spending combo points. This relies on CombatLog entries to detect Parries for instant Riposte casts, completely bypassing the need to have Riposte on your action bar.

Additionally, it features smart target-classification detection to automatically manage major cooldowns and debuffs like Expose Armor based on whether you are fighting normal mobs or Elites/Bosses.

# Important Setup Requirement: 

## ⚠️ Critical Setup Requirement
To allow the addon to manage your auto-attacks smoothly without toggling them off when spamming, you **must** place the standard **Attack** icon (found in the General tab of your Spellbook) onto **Action Slot 12** (the furthest right slot on your main bottom action bar).The addon uses this to reliably force auto-attacks without toggling them off if you spam the macro.

`If using SCRM this is not required and instead just add /startattack to your macro`

Usage : Create a macro with:
`/AutoRogue [nosnd/snd1/snd2] [evis4/evis5] [hemo] [cds] [autocd] [expose]`

- `nosnd` ignore Slice and Dice entirely while you are leveling up.
- `snd1` casts Slice and Dice at 1 combo point.
- `snd2` casts Slice and Dice at 2 combo points [default setting].
- `evis4` casts Eviscerate at 4+ combo points [default setting].
- `evis5` waits to cast Eviscerate until you have exactly 5 combo points.

- `hemo` uses Hemorrhage as your primary combo point builder [default is Sinister Strike].

- `cds` will pop Adrenaline Rush and Blade Flurry on cooldown regardless of target [disabled by default].

- `autocd` will only pop Adrenaline Rush and Blade Flurry if the target is classified as an Elite, Rare Elite, or World Boss [disabled by default].

- `expose` will attempt to apply Expose Armor at 5 combo points if the target is an Elite/Boss and does not already have the debuff [disabled by default].


# Example: 
# The Standard Leveling Setup
`/AutoRogue`

Will function with all default settings. It ensures auto-attack is on, instantly casts Riposte if you parry, applies Slice and Dice at 2 combo points, Eviscerates at 4 combo points, and builds with Sinister Strike.

# The "Smart Boss" Setup
`/AutoRogue snd1 evis5 autocd expose`

On a normal mob, it functions like a standard rotation (SnD at 1 CP, Eviscerates at 5 CP). However, when you target an Elite or Boss, it will intelligently pop Adrenaline Rush and Blade Flurry, build to 5 combo points to cast Expose Armor, and then proceed to spend future 5-point combos on Eviscerate.

# The Subtlety Setup
`/AutoRogue hemo evis5`

Replaces Sinister Strike with Hemorrhage as the combo point builder and waits for 5 full combo points before casting Eviscerate.
