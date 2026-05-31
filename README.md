# ExAutoRogue

An automated combat rotation assistant addon for TurtleWoW (1.12.1 / 1.18.1 API). 

`ExAutoRogue` is designed as a companion project to `ExAutoCSHS`. It automatically manages a Rogue's combat rotation to maintain maximum uptime on **Slice and Dice** while efficiently spending combo points on **Eviscerate**. 

By monitoring the Combat Log directly, the addon instantly detects **Parries** to trigger **Riposte**, completely bypassing the need to keep Riposte on your action bar or handle complex macro race conditions.

---

## ⚠️ Critical Setup Requirement
To allow the addon to manage your auto-attacks smoothly without toggling them off when spamming, you **must** place the standard **Attack** icon (found in the General tab of your Spellbook) onto **Action Slot 12** (the furthest right slot on your main bottom action bar).

---

## Usage & Command Arguments

Create a standard in-game macro and use the following slash command:
```text
/AutoRogue [snd1/snd2] [evis4/evis5] [hemo] [cds] [autocd] [expose]
