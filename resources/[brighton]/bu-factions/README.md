# bu-factions

Every faction gets a real base: a map marker, an enterable interior, a spawn
point and a shared stash.

- **Gangs** (Families, Ballas, Marabunta, Vagos, Bloods) — skull blips in gang
  colors, small house interior, stash blip. Two quest NPCs at the door: house
  robbery and car theft. They hand out lockpicks, reward on completion and go
  on a 5-minute cooldown.
- **Mafias** (Italian, Russian, Mexican, Yakuza) — group blip, mansion
  interior, stash. Quest NPCs: contraband runs to one of four dark buyers in
  hidden spots (3-minute cooldown) and driving prostitutes from the motel to
  clients.
- **Government** (LSPD, hospital, FIB, Weazel News) — office interior, stash
  blip plus a wardrobe blip (criminals dress themselves, so no wardrobe).

The spawn menu lists your faction base when you log in: pick it and you spawn
right at the door.

Storage is a shared qb-inventory stash per faction (`faction-stash-<key>`),
the wardrobe opens the qb-clothing outfit menu.

## Notes

- Interiors are built under the map via `qb-interior` per player.
- Dark buyers are invisible on the map on purpose.
- Door coordinates are provisional — move them in `config.lua`.
