# UPDATE
While the addon still works - all development has been moved to [AEGIS: SBR](https://github.com/Torchlite-bit/Aegis_SBR)

# ExAutoRogue
An Addon for 1.12.1 / 1.18.1 (TurtleWoW) for automatically managing a Rogue's combat rotation to maintain maximum uptime on Slice and Dice while efficiently spending combo points. This addon dynamically reads your spellbook to adapt to your level and talent build, making it perfect for custom servers and unique ability paths.

Inspired by Excinerus' ExAutoCSHS addon, ExAutoRogue relies on CombatLog entries to detect Parries for instant Riposte casts, completely bypassing the need to have it on your action bar or handle macro race conditions.

Version 1.7 introduces a complete graphical configuration panel and database system, moving configuration options out of your macros and into a clean visual window.

# Important Setup Requirement: 

## ⚠️ Critical Setup Requirement
To allow the addon to smoothly manage auto-attacks without toggling them off when spamming, you must place the standard Attack icon (found in the General tab of your Spellbook) anywhere on your action bars. The addon scans all 172 possible action slots to safely trigger weapon swings.

Note: If you use the `SuperCleveRoidMacros` (SCRM) addon, this is not required. You can simply add `/startattack` to the top of your macro.

# 🖥️ Graphical Configuration Panel
You no longer need to type long strings of arguments into your macros. To configure your rotation preferences, simply type the following command in game chat:

`/autorogue ui`

<img width="401" height="469" alt="image" src="https://github.com/user-attachments/assets/ff31f314-3c4b-4003-b31b-52949e584b7a" />

This will toggle a movable, interactive options frame where you can adjust the following settings on the fly:

**- Maintain Slice and Dice (Checkbox):** Toggles whether the addon maintains your SnD uptime. Unchecking this completely ignores SnD (great for pure finisher/burst builds or low-level characters under level 10).

**- Use Major Cooldowns (Checkbox):** When enabled, the addon automatically pops Adrenaline Rush and Blade Flurry.

**- Smart CDs (Elites/Bosses Only) (Checkbox):** When paired with Major Cooldowns, the addon safely stores your cooldowns and only unleashes them if your current target is classified as an Elite, Rare Elite, or World Boss.

**- Eviscerate CP Threshold (Slider):** A smooth slider allowing you to visually snap your desired finishing point anywhere between 1 and 5 combo points.

All choices are instantly saved to the permanent character database (ExAutoRogueDB) and persist across logouts, reloads, and client restarts.

## 🧠 Smart Auto-Detection Features
The core engine handles advanced rotational updates completely under the hood based on your character's current state:

**- Dynamic Builder Upgrades:** The script defaults your builder to Sinister Strike, but automatically switches to Noxious Assault the exact second you train it.

**- Envenom & Poison Weaving:** If you have learned Envenom, it seamlessly weaves it into the rotation as a second maintained buff (tracking the Sword_31 buff aura).

**- Deadly Poison Safety Check:** The engine actively scans your target's debuffs. It will strictly protect you from wasting energy on an Envenom if the target doesn't have active stacks of Deadly Poison, automatically defaulting down to an Eviscerate instead so your combo points never go to waste.

## ⚔️ The Ultimate Combat Macro
Because all configuration logic is handled by the visual interface and database, your in-game macro is now completely streamlined down to a single line:

`/AutoRogue`

# Recommended Setup with SCRM:
If you are running SuperCleveRoidMacros, pair it with an attack starter for the smoothest possible weapon-swing responsiveness:

`/startattack`

`/AutoRogue`

Bind this macro to your main spammable combat key, configure your thresholds inside /autorogue ui, and the script will perfectly manage your builders, custom finishers, priority parry-ripostes, and boss-level cooldown spikes entirely automatically.

<img width="451" height="600" alt="image" src="https://github.com/user-attachments/assets/f5c79a54-3e4c-4a02-a5c0-310db563cb51" />
