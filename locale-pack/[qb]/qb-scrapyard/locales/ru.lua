local Translations = {
    error = {
        smash_own = "Нельзя уничтожать машину её владельцу.",
        cannot_scrap = "Эту машину нельзя разобрать.",
        not_driver = "Вы не водитель",
        demolish_vehicle = "Сейчас нельзя уничтожать машины",
        canceled = "Отменено",
    },
    text = {
        scrapyard = 'Свалка',
        disassemble_vehicle = '[E] - Разобрать машину',
        disassemble_vehicle_target = 'Разобрать машину',
        email_list = "[E] - Список машин на почту",
        email_list_target = "Отправить список машин на почту",
        demolish_vehicle = "Уничтожить машину",
    },
    email = {
        sender = "Turner’s Auto Wrecking",
        subject = "Список машин",
        message = "Вы можете уничтожить только определённое число машин.<br />Всё, что разберёте, можете оставить себе, если не будете мне мешать.<br /><br /><strong>Список машин:</strong><br />",
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
