[Прочитать README на русском языке](README.ru.md)

# Brighton Union

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-Platform-F40552?style=for-the-badge)](https://fivem.net/)
[![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=for-the-badge&logo=lua)](https://www.lua.org/)
[![QBCore](https://img.shields.io/badge/QBCore-2.2.4-ee4f4f?style=for-the-badge)](https://github.com/qbcore-framework/qb-core)

---

## What it is

Brighton Union is an open-source RolePlay server for GTA V on the [FiveM](https://fivem.net/) platform, built on QBCore and fully localized in Russian.

## Local setup

Requirements: Windows, GTA V (Legacy), a free [Cfx.re](https://portal.cfx.re) account.

1. Download the recommended server build from [runtime.fivem.net](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) and extract it into a folder of your choice.
2. Run `FXServer.exe` and complete the txAdmin setup: link your Cfx.re account, set a password, pick **Popular Recipes → QBCore**.
3. Install [XAMPP](https://www.apachefriends.org/) and start MySQL. On the recipe's database step keep the defaults (`localhost`, `3306`, `root`, empty password).
4. Register a free server key at [portal.cfx.re](https://portal.cfx.re/servers/registration-keys) and put it into `sv_licenseKey` in your `server.cfg` (this repository's `server.cfg` can be used as a template).
5. Copy `resources/[brighton]` into your server's `resources/` folder.
6. Run the localization installer: `.\install-locale.ps1 -ServerPath <path to your server data folder>` (for example `...\txData\QBCore_8A0510.base`).
7. Add `ensure bu-locale` to your `server.cfg` and start the server.
8. Join from the FiveM client: press F8 and type `connect localhost`.

## License

MIT — see [LICENSE](LICENSE).

---

**Built by [catelizn](https://github.com/catelizn)**
