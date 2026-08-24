# bu-casino — Casino

Five games behind one NUI at the Diamond Casino entrance: roulette, slot machines, blackjack, poker and mafia.

## House games

- **Roulette** — straight-up 35×, red/black, even/odd, low/high 2×, dozens and columns 3×.
- **Slot machines** — three reels, triple payouts up to 50×.
- **Blackjack** — four decks, aces 1/11, dealer stands on 17, blackjack pays 2.5×, win 2×, push refunds.

All three are server-side: bets 50–50,000, 1 s cooldown, cash validation, single net transaction per round. The client only renders the result.

## Poker (players only)

Texas Hold'em for 2–6 players. Tables are created with a buy-in, chips come from the bank account, the server deals four shuffled decks per table, runs betting rounds and a 90-second turn timer (auto-fold), and evaluates hands at showdown. Winnings stay in chips until the player leaves; unclaimed chips are kept per table.

## Mafia (players only)

A party game for 4–10 players. Roles: mafia, doctor, sheriff, civilians. Night phase (45 s): mafia picks a kill, the doctor picks a save, the sheriff checks a player. Day phase (60 s): discussion and a lynch vote. The server runs all phases, win conditions and announcements.

## Compliance note

There is no real-money exchange: only in-game currency, server-side RNG and bet limits, matching the standard rules for FiveM RP casinos.
