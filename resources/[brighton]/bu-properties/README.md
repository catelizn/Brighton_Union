# bu-properties — Businesses

Buyable businesses behind markers, plus a supply chain that feeds the trucking job.

## Properties

| Property | Price |
| --- | --- |
| LSC auto shop ×4 | $2,500,000 |
| 24/7 store | $1,500,000 |
| Car wash | $900,000 |
| LTD gas station | $1,800,000 |

## Buying and selling

- A marker at each property offers "Купить бизнес" when free and "Продать государству" (50% refund) for the owner. Ownership lives in `bu_properties` and is cached in memory.
- Exports `IsOwner`, `Transfer` and `GetLabel` are used by the marketplace and the auction house. `house:<id>` keys work with QBCore's `player_houses`.

## Supplies

- The owner can order supplies at the marker (1–20 units, $400 each, paid from the bank). This creates a trucking order via `bu-jobs` with a warehouse pickup and the property as the drop point.
- When a trucker delivers, `bu_properties.supplies` increases. The owner can then sell the goods to the state for $500 per unit into their bank account.
- The drop coordinates are persisted per property so orders survive server restarts.
