# bu-rental — Vehicle rental

**Steve Carter** runs the rental stand on the upper level of Los Santos International Airport, next to Mike Ford.

## Fleet

| Vehicle | Price/hour | License |
| --- | --- | --- |
| BMX | $50 | — |
| Faggio | $150 | — |
| Asea | $500 | B |
| Washington | $1000 | B |

## How it works

- The player picks a vehicle and a term of **1, 2 or 3 hours**. The total is `price * hours` and is charged to cash or bank.
- The vehicle is spawned **by the server** at the stand with a `RENTxxx` plate; keys are issued through `qb-vehiclekeys`.
- The menu closes with ESC or the close button; the client watches for the key press even while NUI focus is active.
- An active rental is tracked in memory with its expiry timestamp. A 30-second server loop despawns the vehicle when the term runs out and notifies the player.
- Returning early is only possible within 25 m of the stand. Rentals are also cleaned up on disconnect.
- Every rental is written to `bu_rental_log`, which the tutorial uses to verify its rental stage.

## Phone integration

The **Аренда** app in `qb-phone` displays the active vehicle, its plate and a live countdown. It reads the active rental through the `bu-rental:server:getActive` callback.

## Marketplace integration

`bu-tablet` can hand marketplace rentals to this resource through the `addExternalRental(cid, model, label, plate, hours)` export; the same expiry loop handles them. `finishRental(cid)` is exported for the marketplace auto-return.
