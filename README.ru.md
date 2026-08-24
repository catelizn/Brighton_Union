[Read README in English](README.md)

# Brighton Union

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-Platform-F40552?style=for-the-badge)](https://fivem.net/)
[![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=for-the-badge&logo=lua)](https://www.lua.org/)
[![QBCore](https://img.shields.io/badge/QBCore-2.2.4-ee4f4f?style=for-the-badge)](https://github.com/qbcore-framework/qb-core)

**Made by [catelizn](https://github.com/catelizn)**

---

**Brighton Union** — открытый RolePlay-сервер для GTA V на платформе [FiveM](https://fivem.net/), построенный на QBCore и полностью переведённый на русский. Классический опыт RAGE MP — новичок прилетает в аэропорт, сдаёт на права в автошколе, вступает в семью, торгует на маркетплейсе, играет в казино и участвует в аукционах — перенесён в FiveM, причём каждая механика переработана с нуля, а не скопирована.

## Зачем это существует

Это готовый к адаптации RP-сервер. Каждая система валидируется на сервере, описана в собственном README и рассчитана на полный онлайн без деградации. По сути — референсная архитектура жанра: механики уровня Majestic RP, GTA5RP или NoPixel, реализованные на открытой кодовой базе.

## Карта механик

| Система | Что делает | Подробности |
| --- | --- | --- |
| [Путь новичка](resources/[brighton]/bu-tutorial/README.md) | Кат-сцена прилёта в аэропорт, цепочка Mike Ford | 8 этапов, номер банковского счёта, проверки на сервере |
| [Прокат транспорта](resources/[brighton]/bu-rental/README.md) | Стойка Steve Carter в аэропорту | Срок 1–3 часа, таймер в телефоне, автовозврат |
| [Планшет](resources/[brighton]/bu-tablet/README.md) | Планшет в стиле Apple с 8 приложениями | Документы, маркетплейс, новости, семья, фракция, такси, дальнобой |
| [Автошкола](resources/[brighton]/bu-drivingschool/README.md) | Теория + практика в отдельном мире | Категории A/B/C/LV/LS, белые учебные машины |
| [Движок работ](resources/[brighton]/bu-jobs/README.md) | Работы с уровнями 0–10, найм на месте | NPC в униформе, центральный рынок, заказы такси и дальнобоя |
| [Зелёные зоны](resources/[brighton]/bu-safezones/README.md) | Мирные зоны с индикатором у миникарты | Оружие блокируется, без спама в чат |
| [Семьи и фракции](resources/[brighton]/bu-families/README.md) | Управление организацией из планшета | Казна, аудит-логи, контракты, гараж организации |
| [Документы](resources/[brighton]/bu-documents/README.md) | Фотоателье + документы по клавише P | Паспорт, лицензии, категории прав |
| [Недвижимость](resources/[brighton]/bu-properties/README.md) | Покупка бизнесов через маркер | Поставки товаров, интеграция с дальнобоем |
| [Квартиры](resources/[brighton]/bu-apartments/README.md) | Покупка квартир по сетке номеров | Состояние каждой квартиры, вход внутрь |
| [Казино](resources/[brighton]/bu-casino/README.md) | Рулетка, автоматы, блэкджек, покер, мафия | Серверный RNG, покер и мафия — только игроки |
| [Аукционный дом](resources/[brighton]/bu-auction/README.md) | Живые аукционы на недвижимость, машины, предметы | Комиссия 10%, автосделка |
| [HUD](resources/[brighton]/bu-hud/README.md) | Собственный статус-HUD | Деньги, локация, квест, хоткеи |
| [Weazel News](resources/[brighton]/bu-news/README.md) | Платные объявления в чат и планшет | $500 за объявление, кулдаун 60 с |
| [Локализация](resources/[brighton]/bu-locale/README.md) | Русские названия предметов и работ поверх QBCore | Оверрайды в памяти |

## Что под капотом

- **Вся логика на сервере.** Деньги, предметы, транспорт и игровое состояние проверяются сервером. Клиент только отрисовывает состояние и никогда им не владеет. Никаких дюпов и клиентских «чит-кнопок».
- **Личные инстансы.** Практические экзамены проходят в личном routing bucket игрока: телепорт туда и обратно автоматический.
- **Реальное время.** Время сервера синхронизировано с Москвой (UTC+3). Банки работают до 21:00, банкоматы — круглосуточно.
- **Номера счетов.** У каждого игрока личный номер банковского счёта, по которому идут переводы.
- **Чистый NUI.** Планшет, HUD, казино и аукцион — рукописные HTML/CSS/JS в палитре Brighton Union, без фреймворков и этапа сборки.
- **MariaDB.** Прогресс, лоты, организации, транспорт и недвижимость — в индексированных таблицах с кэшем горячих данных в памяти.

## Установка (локально)

Требования: Windows, GTA V (Legacy), бесплатный аккаунт [Cfx.re](https://portal.cfx.re).

1. Скачайте рекомендованную сборку сервера с [runtime.fivem.net](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) и распакуйте её в удобную папку.
2. Запустите `FXServer.exe` и пройдите настройку txAdmin: привяжите аккаунт Cfx.re, задайте пароль, выберите **Popular Recipes → QBCore**.
3. Установите [XAMPP](https://www.apachefriends.org/) и запустите MySQL. На шаге настройки базы в рецепте оставьте значения по умолчанию (`localhost`, `3306`, `root`, пустой пароль).
4. Получите бесплатный ключ на [portal.cfx.re](https://portal.cfx.re/servers/registration-keys) и вставьте его в `sv_licenseKey` в своём `server.cfg` (можно взять `server.cfg` из этого репозитория как шаблон).
5. Скопируйте `resources/[brighton]` в папку `resources/` вашего сервера.
6. Запустите установщик локализации: `.\install-locale.ps1 -ServerPath <путь к папке данных сервера>` (например `...\txData\QBCore_8A0510.base`). Он скопирует локализованные файлы QBCore из `locale-pack/`.
7. Добавьте блок `ensure bu-*` из `server.cfg` этого репозитория в свой конфиг в том же порядке и запустите сервер.
8. Зайдите с клиента FiveM: нажмите F8 и введите `connect localhost`.

## Структура проекта

```
resources/[brighton]/   # оригинальные системы Brighton Union (папка на механику)
locale-pack/            # локализованные копии пропатченных файлов QBCore
docs/research/          # заметки по дизайну, палитра, карта механик
server.cfg              # эталонная конфигурация
install-locale.ps1      # применяет locale-pack к серверу QBCore
BRIEF.md                # бриф проекта и дизайн-решения
```

## Лицензия

MIT — см. [LICENSE](LICENSE). Форкайте, запускайте, меняйте. Упоминание авторства приветствуется.

---

**Built by [catelizn](https://github.com/catelizn)**
