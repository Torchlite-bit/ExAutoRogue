# ExAutoRogue Changelog

All notable changes to this addon, relative to the original v1.3.
## [1.7]

### Added
- **Graphical User Interface (GUI).** Built a pure Lua visual configuration panel (`ExAutoRogueUI`) using standard WoW frame templates. The panel features a movable window, a gold title header, interactive checkboxes, and an adjustable slider.
- **Persistent Storage (SavedVariables).** Integrated `ExAutoRogueDB` database support to permanently save user settings across character reloads, logouts, and client restarts. 
- **Interactive Toggles & Sliders.** 
  - Added checkboxes for **Maintain Slice and Dice**, **Use Major Cooldowns**, and **Smart CDs (Elites/Bosses Only)**.
  - Added a dynamic **Eviscerate CP Threshold** slider that lets players visually snap their finishing point anywhere between 1 and 5 combo points.
- **New Interface Command.** Expanded the global slash command so typing `/autorogue ui` in chat cleanly toggles the configuration panel on and off.

### Changed
- **Database-Driven Rotation Engine.** Completely overhauled `ExAutoRogue:EvalCommand()`. The combat engine no longer wastes performance parsing text strings inside a macro; it now instantly references the saved database parameters to evaluate priorities.

### Removed
- **Manual Macro Arguments.** Removed macro text string scanning (`nosnd`, `evis4`, `evis5`, `cds`, `autocd`). Users no longer need to type long, clunky command chains into their macro frames.

## [1.6]

### Added
- **Deadly Poison Stack Tracking.** Added `ExAutoRogue:GetDebuffStacks(textureName)` to accurately read the number of applications of a specific debuff on the target.

### Changed
- **Smart Envenom Protection.** Envenom is now guarded by a poison check. The script verifies that the target has at least 1 stack of Deadly Poison (using the `ability_rogue_dualweild` texture) before attempting to cast Envenom. This prevents wasting energy and combo points on a 0-damage finisher.
- **Dynamic Buff Refresh.** Maintained buffs (Slice and Dice, Envenom) now simply refresh using all currently available combo points the moment the buff drops. This prevents the script from forcing painfully weak (1 or 2 CP) Eviscerates just to clear the board for a 1 CP refresh.

### Removed
- **Timer-based predictive refresh.** Removed the `sndExpire`, `envExpire`, `SND_DUR`, and `ENV_DUR` predictive variables. Because the Vanilla `CastSpellByName()` API does not natively report if a cast failed due to low energy, the timer logic was prone to "false positives" where the script believed a buff was successfully applied when it actually failed, causing the rotation to stall. Texture presence is now the strict, sole source of truth.

## [1.5]

### Changed
- **Auto-attack now scans every action slot instead of requiring a fixed slot.**
  Added `ExAutoRogue:EnsureAutoAttack()`, which loops over all action slots
  (1-172, every bar), finds the Attack action via `IsAttackAction(z)` and
  triggers it with `UseAction(z)` only when it is not already current. The
  Attack button may now sit anywhere on any bar.

### Removed
- Removed the hardcoded action-slot logic and the `ATTACK_SLOT` constant.
  Setup no longer requires placing Attack on a specific slot.

### Notes
- The slot scan uses `UseAction(z)` (matching the paladin macro it was based
  on) rather than `CastSpellByName("Attack")`. For a plain auto-attack the two
  are equivalent. For a class with on-next-swing abilities (Heroic Strike,
  Cleave, Maul, Raptor Strike) this would need closer attention, but it is
  irrelevant for the Rogue.

## [1.4]

### Added
- **Generic spellbook detection.** `ExAutoRogue:KnowsSpell(spellName)` scans
  the spellbook and matches across all ranks (rank suffix ignored).
  `ExAutoRogue:Cast(spellName)` only casts spells the character actually knows.
  Unlearned spells (whether due to level or talent) no longer cast into the
  void. The check runs fresh on every keypress, so spells learned mid-session
  are picked up immediately.
- **Automatic builder switch.** Builder defaults to Sinister Strike and
  switches to Noxious Assault automatically once that spell is learned.
- **Envenom support.** Envenom is tracked as a second maintained buff (texture
  `Sword_31`) and becomes active automatically once learned, using the same
  refresh logic as Slice and Dice.
- **Timer-based buff refresh.** Slice and Dice and Envenom now refresh roughly
  `BUFF_RENEW` (5) seconds before expiry using remembered expiry timestamps
  (`sndExpire`, `envExpire`) and per-combo-point duration tables (`SND_DUR`,
  `ENV_DUR`), instead of only refreshing after the buff falls off. Texture
  presence remains the source of truth and serves as a fallback when the timer
  is unknown (for example when the macro is first pressed mid-combat).
- **Cheapest-possible refresh.** When a maintained buff is expiring and more
  than 1 combo point is available, Eviscerate is dumped first, then the buff is
  refreshed at exactly 1 combo point so surplus points go to damage.

### Changed
- **Riposte is now guarded by spell knowledge.** The Riposte branch only fires
  when Riposte is actually in the spellbook. Previously the combat-log parry
  window forced the branch unconditionally, which on a spec without Riposte
  cast into the void and stalled the rotation for ~5.5 seconds after every
  parry. The combat-log listener stays inert when Riposte is not learned.
- Eviscerate threshold remains configurable via `evis4` (default) and `evis5`.

### Removed
- Removed the `snd1`/`snd2` options. Cheapest refresh at 1 combo point is now
  built in and no longer needs a switch.
