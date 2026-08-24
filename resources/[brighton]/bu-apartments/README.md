# bu-apartments — Apartments

Apartment buildings with a numbered purchase grid, exactly like the classic RP model.

## Buildings

| Building | Door | Flats | Price |
| --- | --- | --- | --- |
| Южный Рокфорд-Драйв | -667, -1105 | 24 | $150,000 |
| Морнингвуд-Бульвар | -1288, -430 | 24 | $180,000 |
| Интегрити-Уэй | 269, -640 | 24 | $160,000 |

## Purchase grid

The door marker opens a grid of numbered flats with three states:

- **Grey** — owned by someone else.
- **Neutral with price** — free, click to buy (bank payment, one flat per building per player).
- **Green** — yours; clicking teleports you inside.

## Interiors

Each flat gets its own furnished interior (`qb-interior` apartment shell) placed at `door.z - (300 + number * 3)` so flats never overlap. Exiting despawns the interior and returns the player to the door.

Ownership lives in `bu_apartments` with a unique `(building, number)` key; the auction house can transfer flats by row id.
