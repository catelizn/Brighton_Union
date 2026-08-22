local Translations = {
    error = {
        minimum_store_robbery_police = "Недостаточно полиции (требуется %{MinimumStoreRobberyPolice})",
        not_driver = "Вы не водитель",
        demolish_vehicle = "Сейчас нельзя уничтожать машины",
        process_canceled = "Процесс отменён..",
        you_broke_the_lock_pick = "Вы сломали отмычку",
    },
    text = {
        the_cash_register_is_empty = "Касса пуста",
        try_combination = "~g~E~w~ - Попробовать комбинацию",
        safe_opened = "Сейф открыт",
        emptying_the_register= "Опустошаем кассу..",
        safe_code = "Код сейфа: "
    },
    email = {
        shop_robbery = "10-31 | Ограбление магазина",
        someone_is_trying_to_rob_a_store = "Кто-то пытается ограбить магазин на %{street} (ID КАМЕРЫ: %{cameraId1})",
        storerobbery_progress = "Ограбление магазина в процессе"
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
