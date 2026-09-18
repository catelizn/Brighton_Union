# Troubleshooting и нюансы отладки Brighton Union

Внутренний документ для отладки сервера. Обновляется по мере находок.

## Очистка кэша FiveM перед тестом

После ЛЮБОЙ правки HTML/CSS/JS (или добавления/правки NUI-ресурса) клиент FiveM
показывает СТАРОЕ содержимое, пока не очистит кэш. Обязательно чистить перед тестом:

```
%LOCALAPPDATA%\FiveM\FiveM.app\data\cache
```

Очищать содержимое папки `cache` (FiveM при этом закрыт). Быстрее всего:

```powershell
Remove-Item -LiteralPath "$env:LOCALAPPDATA\FiveM\FiveM.app\data\cache\*" -Recurse -Force
```

Если изменения не применились, а кэш почищен — рестартнуть ресурс (или перезайти на сервер).

## Полоски здоровья/брони под миникартой

- Это НЕ HUD-компонент: полоски рисует scaleform `minimap.gfx`, поэтому
  `HideHudComponentThisFrame(4/5/6/19)` НЕ работает. Отдельного натива нет.
- Решение — клиентский тред в `resources/[brighton]/bu-hud/client/main.lua`,
  который постоянно перезаписывает `healthType` через scaleform `minimap`:

```lua
CreateThread(function()
    local minimap = RequestScaleformMovie('minimap')
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, 'SETUP_HEALTH_ARMOUR')
        ScaleformMovieMethodAddParamInt(3) -- 3 = GOLF: полоски не рисуются
        EndScaleformMovieMethod()
    end
end)
```

## Телефон qb-phone — наложение двух макетов

- После рестайла в `html/index.html` остались ОБА макета: стоковый QBCore-телефон
  (Samsung-рамка `phone-frame` + домашний экран `phone-applications`) и добавленный
  поверх iPhone-лок. При открытии они показывались одновременно.
- Решение в `html/js/app.js`:
  - в `ShowLockScreen()` скрыть `.phone-frame`, `.phone-header`, `.phone-applications`;
  - после разблокировки (`click` по `#lock-screen` → `addClass('unlocked')`) показать
    `.phone-header` и `.phone-applications`.

## Частые технические нюансы

- **oxmysql:** глобал `MySQL` доступен, только если ресурс подключает
  `'@oxmysql/lib/MySQL.lua'` в `shared_scripts` и `oxmysql` в `dependencies`.
  Иначе `MySQL = nil`: прямой вызов падает, а цикл `while not MySQL do Wait(100) end`
  крутится вечно МОЛЧА (ресурс не инициализирует БД).
- **Проверка Lua-синтаксиса:** `get_errors` НЕ ловит ошибки Lua. Обязательно прогонять
  `node check.js <пути>` в `%TEMP%\luacheck-bu` (luaparse). Наши bu-* пишутся на чистом
  Lua, стоковые qb-* дают ложные ошибки (backtick, `+=`, `<const>` и т.п.).
- **Деплой:** правки делаются в репо (`resources/...`, `locale-pack/...`), затем
  копируются в `txData/...` по одному файлу (`Copy-Item -Force`). `Copy-Item -Recurse`
  НЕ перезаписывает изменённые файлы.
- **PowerShell:** пути с `[qb]` / `[brighton]` — wildcard, использовать только
  `-LiteralPath`; `.ps1` с кириллицей сохранять UTF-8 с BOM; Lua-файлы — UTF-8 БЕЗ BOM.
- **NUI/ESC:** при `NuiFocus` клавиатура уходит в NUI, клавишу ловить через
  `IsControlJustPressed(0, 202)` в треде на клиенте.
- **git push:** пишет в stderr → PowerShell показывает `NativeCommandError` и exit 1.
  Это НЕ ошибка, смотреть строку `<hash> main -> main`.
- **Секреты:** перед коммитом `git grep --cached -n -E 'sv_licenseKey|cfxk_|rcon_password'`.
