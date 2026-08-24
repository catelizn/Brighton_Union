[Прочитать README на русском языке](README.ru.md)

# Brighton Union

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-Platform-F40552?style=for-the-badge)](https://fivem.net/)
[![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=for-the-badge&logo=lua)](https://www.lua.org/)
[![QBCore](https://img.shields.io/badge/QBCore-2.2.4-ee4f4f?style=for-the-badge)](https://github.com/qbcore-framework/qb-core)

**Made by [catelizn](https://github.com/catelizn)**

---

Brighton Union is an open-source RolePlay server for GTA V on the [FiveM](https://fivem.net/) platform, built on QBCore and fully localized in Russian. It ports the classic RAGE MP experience — newcomers arriving at the airport, a driving school with real exams, family and faction systems, a player marketplace, a casino and an auction house — into FiveM, with every mechanic redesigned rather than copied.

## Why it exists

This is a complete, ready-to-adapt RP server. Every system is server-authoritative, documented in its own README, and designed to survive a full server without falling over. Think of it as a reference architecture for the genre: the mechanics you normally see on Majestic RP, GTA5RP or NoPixel, implemented from scratch on an open codebase.

## Feature map

| System | What it does | Details |
| --- | --- | --- |
| [Newcomer path](resources/[brighton]/bu-tutorial/README.md) | Airport arrival cinematic, Mike Ford quest chain | 8 stages, bank account number, server-side checks |
| [Vehicle rental](resources/[brighton]/bu-rental/README.md) | Steve Carter's rental stand at the airport | 1–3 hour terms, phone timer, auto return |
| [Tablet](resources/[brighton]/bu-tablet/README.md) | Apple-style tablet with 8 applications | Documents, marketplace, news, family, faction, taxi, trucking |
| [Driving school](resources/[brighton]/bu-drivingschool/README.md) | Theory exam + driving tests in a private instance | Categories A/B/C/LV/LS, white training cars |
| [Jobs engine](resources/[brighton]/bu-jobs/README.md) | Leveled jobs 0–10 with on-site hiring | Uniformed NPCs, central market, taxi & trucking orders |
| [Safe zones](resources/[brighton]/bu-safezones/README.md) | Green zones with a minimap indicator | Weapons blocked, zero chat spam |
| [Families & factions](resources/[brighton]/bu-families/README.md) | Tablet-managed organizations | Treasury, audit logs, contracts, org garage |
| [Documents](resources/[brighton]/bu-documents/README.md) | Photo studio + P-key documents UI | Passport, licenses, driving categories |
| [Properties](resources/[brighton]/bu-properties/README.md) | Buyable businesses via markers | Supply orders, trucking integration |
| [Apartments](resources/[brighton]/bu-apartments/README.md) | Apartment grid purchase at building doors | Per-flat state, walk-in interiors |
| [Casino](resources/[brighton]/bu-casino/README.md) | Roulette, slots, blackjack, poker, mafia | Server-side RNG, player-only poker/mafia |
| [Auction house](resources/[brighton]/bu-auction/README.md) | Live auctions for property, vehicles, items | 10% commission, auto-settlement |
| [HUD](resources/[brighton]/bu-hud/README.md) | Custom status HUD | Money, location, quest progress, hotkeys |
| [Weazel News](resources/[brighton]/bu-news/README.md) | Paid ads broadcast to chat and the tablet | $500 per ad, 60s cooldown |
| [Locale pack](resources/[brighton]/bu-locale/README.md) | Russian item/job labels on top of QBCore | In-memory overrides |

## What's under the hood

- **Server-authoritative by design.** Money, items, vehicles and game state are validated on the server. Clients render state, they never own it. No dupes, no client-side "press F to become rich".
- **Private instances.** Driving exams run in a per-player routing bucket; the player is teleported in and out automatically.
- **Real-time sync.** Server time follows Moscow (UTC+3). Banks close at 21:00, ATMs work around the clock.
- **Bank account numbers.** Every player gets a personal account number used for bank transfers, like a real IBAN-lite.
- **Vanilla NUI.** The tablet, HUD, casino and auction UIs are hand-written HTML/CSS/JS with the Brighton Union palette — no frameworks, no build step.
- **MariaDB-backed.** Progress, listings, organizations, vehicles and properties live in indexed tables with in-memory caches for hot data.

## Local setup

Requirements: Windows, GTA V (Legacy), a free [Cfx.re](https://portal.cfx.re) account.

1. Download the recommended server build from [runtime.fivem.net](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) and extract it into a folder of your choice.
2. Run `FXServer.exe` and complete the txAdmin setup: link your Cfx.re account, set a password, pick **Popular Recipes → QBCore**.
3. Install [XAMPP](https://www.apachefriends.org/) and start MySQL. Keep the recipe's database defaults (`localhost`, `3306`, `root`, empty password).
4. Register a free server key at [portal.cfx.re](https://portal.cfx.re/servers/registration-keys) and put it into `sv_licenseKey` in your `server.cfg` (this repository's `server.cfg` works as a template).
5. Copy `resources/[brighton]` into your server's `resources/` folder.
6. Run the localization installer: `.\install-locale.ps1 -ServerPath <path to your server data folder>` (for example `...\txData\QBCore_8A0510.base`). It copies the localized QBCore files from `locale-pack/`.
7. Add the `ensure bu-*` block from this repository's `server.cfg` to yours, in the same order, then start the server.
8. Join from the FiveM client: press F8 and type `connect localhost`.

## Project layout

```
resources/[brighton]/   # original Brighton Union systems (one folder per mechanic)
locale-pack/            # localized copies of the stock QBCore files that were patched
docs/research/          # design notes, brand palette, mechanics map
server.cfg              # reference configuration
install-locale.ps1      # applies locale-pack to a QBCore server
BRIEF.md                # project brief and design decisions (Russian)
```

## License

MIT — see [LICENSE](LICENSE). Fork it, run it, change it. Attribution is appreciated.

---

**Built by [catelizn](https://github.com/catelizn)**

