local Translations = {
    success = {
        you_have_been_clocked_in = "Вы вышли на смену",
        sold = 'Вы продали %{amount} x %{item} за $%{price}',
    },
    text = {
        point_enter_warehouse = "[E] Войти на склад",
        enter_warehouse= "Войти на склад",
        exit_warehouse= "Покинуть склад",
        point_exit_warehouse = "[E] Покинуть склад",
        toggle_duty = "Смена",
        point_toggle_duty = "[E] Начать/закончить смену",
        hand_in_package = "Сдать посылку",
        point_hand_in_package = "[E] Сдать посылку",
        get_package = "Взять посылку",
        point_get_package = "[E] Взять посылку",
        picking_up_the_package = "Забираем посылку",
        unpacking_the_package = "Распаковываем посылку",
        clock_in = "Вы вышли на смену",
        clock_out = "Вы закончили смену",
        sell_materials = "Продать материалы",
        point_sell_materials = "[E] Продать материалы",
        price = "Цена: $%{price}",
        amount = "Количество",
        sell = "Продать",
    },
    error = {
        you_have_clocked_out = "Вы закончили смену",
        nothing_to_sell = "Вам нечего продавать",
        out_of_stock = "%{item} закончился",
        too_far_to_sell = "Вы слишком далеко, чтобы продавать",
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
