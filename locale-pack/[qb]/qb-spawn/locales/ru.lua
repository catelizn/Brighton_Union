local Translations = {
    ui = {
        last_location = "Последнее местоположение",
        confirm = "Подтвердить",
        where_would_you_like_to_start = "Где вы хотите начать?",
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
