local Translations = {
    text = {
        weazle_overlay = "Наложение Weazle ~INPUT_PICKUP~ \nНаложение плёнки: ~INPUT_INTERACTION_MENU~",
        vehicle = "Машины Weazel News",
        close_menu = "⬅ Закрыть меню",
        heli = "Вертолёты Weazel News",
        store_vehicle = "~g~E~w~ - Поставить машину",
        vehicles = "~g~E~w~ - Машины",
        store_helicopters = "~g~E~w~ - Поставить вертолёты",
        helicopters = "~g~E~w~ - Вертолёты",
        enter = "~g~E~w~ - Войти",
        go_outside = "~g~E~w~ - Выйти на улицу",
        breaking_news = "ЭКСТРЕННЫЕ НОВОСТИ",
        title_breaking_news = "7:00 / Сегодня, эксклюзив Weazel News",
        bottom_breaking_news = "Мы показываем ПОСЛЕДНИЕ НОВОСТИ в прямом эфире"
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
