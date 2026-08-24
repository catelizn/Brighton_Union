# bu-safezones — Green zones

Peaceful areas where weapons are unusable: Legion Square, city hall, hospital, bank, both driving schools and the LSIA airport.

## How it works

- A single 500 ms client loop checks whether the player is inside any configured zone.
- Inside a zone the equipped weapon is holstered and attack/aim/melee controls are disabled for that frame.
- Instead of chat spam, a small **"ЗЕЛЁНАЯ ЗОНА"** badge with the zone name appears next to the minimap, styled with the Brighton Union palette. It disappears the moment the player leaves.
- Friendly fire is already off in QBCore; this layer only removes the weapon threat.

## Config

Zones, radii and blocked controls live in `config.lua`. Adding a zone is a one-line entry.
