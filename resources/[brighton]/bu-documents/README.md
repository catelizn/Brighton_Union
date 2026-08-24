# bu-documents — Documents & photo studio

A dedicated photo studio (its own building with a walk-in interior) plus a documents UI on the **P** key.

## Photo studio

- The studio door has a blip and a target prompt. Entering spawns a small store interior below the map and a photographer NPC inside.
- "Take a document photo" fades the screen, writes `metadata.photodate` server-side and notifies the player. The date shows up in the passport tab and the tablet's personal data.

## Documents UI (P)

Three tabs, data from the same callback the tablet uses:

1. **Паспорт** — name, birthdate, nationality, gender, photo date.
2. **Лицензии** — hunting/fishing/weapon licenses and the ID card.
3. **Права на транспорт** — the merged driving categories from the `driver_license` item.

The same UI opens from the phone **Документы** app, which closes the phone and triggers the P-menu.
