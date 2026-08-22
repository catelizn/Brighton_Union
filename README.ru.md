[Read README in English](README.md)

# Brighton Union

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-Platform-F40552?style=for-the-badge)](https://fivem.net/)
[![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=for-the-badge&logo=lua)](https://www.lua.org/)
[![QBCore](https://img.shields.io/badge/QBCore-2.2.4-ee4f4f?style=for-the-badge)](https://github.com/qbcore-framework/qb-core)

---

## Что это

**Brighton Union** — открытый RolePlay-сервер для GTA V на платформе [FiveM](https://fivem.net/), построенный на QBCore и полностью переведённый на русский язык.

## Установка (локально)

Требования: Windows, GTA V (Legacy), бесплатный аккаунт [Cfx.re](https://portal.cfx.re).

1. Скачайте рекомендованную сборку сервера с [runtime.fivem.net](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) и распакуйте её в удобную папку.
2. Запустите `FXServer.exe` и пройдите настройку txAdmin: привяжите аккаунт Cfx.re, задайте пароль, выберите **Popular Recipes → QBCore**.
3. Установите [XAMPP](https://www.apachefriends.org/) и запустите MySQL. На шаге настройки базы в рецепте оставьте значения по умолчанию (`localhost`, `3306`, `root`, пустой пароль).
4. Получите бесплатный ключ на [portal.cfx.re](https://portal.cfx.re/servers/registration-keys) и вставьте его в `sv_licenseKey` в своём `server.cfg` (можно взять `server.cfg` из этого репозитория как шаблон).
5. Скопируйте `resources/[brighton]` в папку `resources/` вашего сервера.
6. Запустите установщик перевода: `.\install-locale.ps1 -ServerPath <путь к папке данных сервера>` (например `...\txData\QBCore_8A0510.base`).
7. Добавьте `ensure bu-locale` в `server.cfg` и запустите сервер.
8. Зайдите с клиента FiveM: нажмите F8 и введите `connect localhost`.

## Лицензия

MIT — см. [LICENSE](LICENSE).

---

**Built by [catelizn](https://github.com/catelizn)**
