local Translations = {
    weather = {
        now_frozen = 'Погода заморожена.',
        now_unfrozen = 'Погода больше не заморожена.',
        invalid_syntax = 'Неверный синтаксис, правильно: /weather <тип погоды> ',
        invalid_syntaxc = 'Неверный синтаксис, используйте /weather <тип погоды>!',
        updated = 'Погода обновлена.',
        invalid = 'Неверный тип погоды, доступные типы: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ',
        invalidc = 'Неверный тип погоды, доступные типы: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ',
        willchangeto = 'Погода изменится на: %{value}.',
        accessdenied = 'Доступ к команде /weather запрещён.',
    },
    dynamic_weather = {
        disabled = 'Динамическая смена погоды выключена.',
        enabled = 'Динамическая смена погоды включена.',
    },
    time = {
        frozenc = 'Время заморожено.',
        unfrozenc = 'Время больше не заморожено.',
        now_frozen = 'Время заморожено.',
        now_unfrozen = 'Время больше не заморожено.',
        morning = 'Установлено утро.',
        noon = 'Установлен полдень.',
        evening = 'Установлен вечер.',
        night = 'Установлена ночь.',
        change = 'Время изменено на %{value}:%{value2}.',
        changec = 'Время изменено на: %{value}!',
        invalid = 'Неверный синтаксис, правильно: time <час> <минута> !',
        invalidc = 'Неверный синтаксис. Используйте /time <час> <минута>!',
        access = 'Доступ к команде /time запрещён.',
    },
    blackout = {
        enabled = 'Блэкаут включён.',
        enabledc = 'Блэкаут включён.',
        disabled = 'Блэкаут выключен.',
        disabledc = 'Блэкаут выключен.',
    },
    help = {
        weathercommand = 'Сменить погоду.',
        weathertype = 'тип погоды',
        availableweather = 'Доступные типы: extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, snow, blizzard, snowlight, xmas и halloween',
        timecommand = 'Сменить время.',
        timehname = 'часы',
        timemname = 'минуты',
        timeh = 'Число от 0 до 23',
        timem = 'Число от 0 до 59',
        freezecommand = 'Заморозить / разморозить время.',
        freezeweathercommand = 'Включить/выключить динамическую смену погоды.',
        morningcommand = 'Установить время 09:00',
        nooncommand = 'Установить время 12:00',
        eveningcommand = 'Установить время 18:00',
        nightcommand = 'Установить время 23:00',
        blackoutcommand = 'Переключить режим блэкаута.',
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
