# bu-families — Families & factions

Organizations managed entirely from the tablet: creation, ranks, treasury, audit logs, contracts and an organization garage. Families and factions share the same engine with different settings.

## Settings

| | Family | Faction |
| --- | --- | --- |
| Creation price | $25,000 | $150,000 |
| Max rank (leader) | 10 | 12 |
| Max members | 20 | 30 |

## Features

- **Creation** from the tablet; the price is charged to the bank account, names are unique and 3–24 characters.
- **Invites** (`/finvite` + `/faccept`) and tablet-based rank changes and kicks, leader-only.
- **Treasury**: any member deposits cash (`/fdeposit` or tablet), only the leader withdraws.
- **Audit logs** (`bu_family_logs`, leader-only view): who joined, was kicked, deposited, withdrew, bought/took/returned vehicles and completed contracts.
- **Contracts**: delivery jobs from a random pickup to a drop point; the reward goes straight into the treasury. One active contract per organization.
- **Garage**: the leader buys vehicles from the treasury (catalog in `config.lua`); members take and return them through the phone Parking app at city parking points.

## Vehicle calling

The phone **Парковка** app lists parking points, the player's own vehicles and organization vehicles. Calling a personal vehicle flips its garage state and spawns it at the nearest parking point; parking it restores the state and garage. All operations are distance-validated on the server.
