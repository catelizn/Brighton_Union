local Translations = {
    error = {
        ["invalid_job"] = "Кажется, я здесь не работаю...",
        ["invalid_items"] = "У вас нет нужных предметов!",
        ["no_items"] = "У вас нет никаких предметов!",
    },
    progress = {
        ["pick_grapes"] = "Собираем виноград ..",
        ["process_grapes"] = "Перерабатываем виноград ..",
    },
    task = {
        ["start_task"] = "[E] Начать",
        ["load_ingrediants"] = "[E] Загрузить ингредиенты",
        ["wine_process"] = "[E] Начать производство вина",
        ["get_wine"] = "[E] Забрать вино",
        ["make_grape_juice"] = "[E] Сделать виноградный сок",
        ["countdown"] = "Осталось %{time} сек",
        ['cancel_task'] = "Вы отменили задание"
    },
    text = {
        ["start_shift"] = "Вы начали смену на винограднике!",
        ["end_shift"] = "Ваша смена на винограднике закончилась!",
        ["valid_zone"] = "Верная зона!",
        ["invalid_zone"] = "Неверная зона!",
        ["zone_entered"] = "Вы вошли в зону %{zone}",
        ["zone_exited"] = "Вы вышли из зоны %{zone}",
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
