# bu-interact

Shared interaction library for Brighton Union resources.

Exports:

- `spawnPed(model, coords, opts)` — client-side ped with ground snap, freeze,
  invincibility, optional scenario, blip and [E] action. `coords` is a vector4.
- `addPoint(coords, radius, opts)` — visible ground marker with 3D label and [E]
  action. Returns a point id for `removePoint`.
- `removePoint(id)`, `removePed(ped)`
- `addBlip(coords, opts)`

Options: `label`, `action`, `canInteract`, `scenario`, `blip`,
`color` (RGBA table), `size`, `snapZ`, `shortRange`.
