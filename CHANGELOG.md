# ExAutoRogue Changelog

All notable changes to this addon, relative to the original v1.3.

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
