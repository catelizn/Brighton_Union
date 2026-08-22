local Translations = {
    error = {
        fingerprints = 'Вы оставили отпечаток на стекле',
        minimum_police = 'Требуется минимум %{value} полицейских',
        wrong_weapon = 'Ваше оружие недостаточно мощное..',
        to_much = 'У вас слишком много всего в карманах'
    },
    success = {},
    info = {
        progressbar = 'Разбиваем витрину',
    },
    general = {
        target_label = 'Разбить витрину',
        drawtextui_grab = '[E] Разбить витрину',
        drawtextui_broken = 'Витрина разбита'
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
