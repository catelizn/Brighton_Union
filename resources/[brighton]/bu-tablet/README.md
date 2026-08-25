# bu-tablet — Tablet

An Apple-style tablet opened with the **DOWN arrow**. Vanilla HTML/CSS/JS, no build step, Brighton Union palette.

## Applications

| App | Purpose |
| --- | --- |
| Документы | Personal data (name, birthdate, nationality, photo date) and licenses with driving categories |
| Транспорт | Player vehicles with brand/model labels |
| Маркетплейс | Item / property listings, 5% commission, offline payouts, vehicle rentals, favourites, view counters, filters |
| Weazel News | News feed and paid ad submission |
| Семья | Full family management: create, members, ranks, treasury, audit logs, contracts, garage |
| Фракция | Same management model for factions (higher ranks, own price) |
| Brighton Taxi | Player taxi orders: distance pricing, +30% over NPC rates |
| Дальнобой | Trucking orders from player businesses + 5 NPC routes |

## Marketplace rules

- Items are removed from the seller's inventory the moment a listing is created — no dupes.
- Max 10 active listings per player, price cap $10,000,000.
- Removing an item listing costs $1,000 from the bank; property and rental lots are free to remove (the vehicle returns to the garage).
- Showcase filters: all / items / property / rentals / favourites. Every lot tracks views and favourites.
- Property lots transfer ownership through `bu-properties` exports.
- Vehicle rental lots set the vehicle to a hidden garage state, hand the car to the renter via `bu-rental`, and return it to the owner's garage when the term expires.

## Architecture

The NUI fetches `https://bu-tablet/<action>` callbacks; the client bridges them to server callbacks and events. All mutations are validated server-side.
