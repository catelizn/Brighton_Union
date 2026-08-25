# bu-auction — Auction house

A dedicated auction hall with live timed auctions for houses, apartments, businesses, vehicles and items.

## Selling

Inside the hall the player picks a lot from what they actually own (validated server-side): a business, a house, an apartment, a vehicle from their garage or an inventory item. Items are removed on listing (no dupes); vehicles are hidden from garages while listed. Starting prices run from $1,000 to $10,000,000, duration 1–60 minutes.

## Bidding

Any player except the seller can bid; the bid is the current price (or the start price) plus a 10% step, with ×1/×3/×5 multipliers. Funds are checked at bid time, money is charged only when the auction ends. A bid in the last 60 seconds extends the timer by a minute (anti-snipe).

## Settlement

A 1-second server loop closes auctions when the timer runs out:

- The winner pays from the bank, the seller receives the price minus a 10% commission (offline sellers are credited through their stored money JSON).
- Ownership transfers via the corresponding system: `bu-properties` exports for businesses, `player_houses` update for houses, `bu_apartments` row for flats, `player_vehicles` citizenid for cars, `AddItem` for items.
- With no bids the lot returns to the seller.

The hall itself is a `qb-interior` office shell behind a door marker with an exit zone.
