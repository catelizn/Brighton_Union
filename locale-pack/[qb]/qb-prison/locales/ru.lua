local Translations = {
    error = {
        ["missing_something"] = "Похоже, вам чего-то не хватает...",
        ["not_enough_police"] = "Недостаточно полиции..",
        ["door_open"] = "Дверь уже открыта..",
        ["cancelled"] = "Процесс отменён..",
        ["didnt_work"] = "Не получилось..",
        ["emty_box"] = "Коробка пуста..",
        ["injail"] = "Вы в тюрьме ещё %{Time} месяцев..",
        ["item_missing"] = "Вам не хватает предмета..",
        ["escaped"] = "Вы сбежали... Убирайтесь отсюда.!",
        ["do_some_work"] = "Поработайте для сокращения срока, доступная работа: %{currentjob} ",
        ["security_activated"] = "Активирован высший уровень охраны, оставайтесь у камер!"
    },
    success = {
        ["found_phone"] = "Вы нашли телефон..",
        ["time_cut"] = "Вы отработали часть срока.",
        ["free_"] = "Вы свободны! Наслаждайтесь! :)",
        ["timesup"] = "Ваш срок истёк! Отметьтесь у выхода",
    },
    info = {
        ["timeleft"] = "Вам осталось... %{JAILTIME} месяцев",
        ["lost_job"] = "Вы безработный",
        ["job_interaction"] = "[E] Работа с электрикой",
        ["job_interaction_target"] = "Выполнить работу %{job}",
        ["received_property"] = "Ваше имущество возвращено..",
        ["seized_property"] = "Ваше имущество изъято, вы получите всё обратно по истечении срока..",
        ["cells_blip"] = "Камеры",
        ["freedom_blip"] = "Выход из тюрьмы",
        ["canteen_blip"] = "Столовая",
        ["work_blip"] = "Тюремные работы",
        ["target_freedom_option"] = "Проверить срок",
        ["target_canteen_option"] = "Получить еду",
        ["police_alert_title"] = "Новый вызов",
        ["police_alert_description"] = "Побег из тюрьмы",
        ["connecting_device"] = "Подключаем устройство",
        ["working_electricity"] = "Соединяем провода"
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
