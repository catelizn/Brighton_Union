local Translations = {
    error = {
        no_money = 'Недостаточно денег',
        too_far = 'Вы слишком далеко от своей точки с хот-догами',
        no_stand = 'У вас нет точки с хот-догами',
        cust_refused = 'Клиент отказался!',
        no_stand_found = 'Ваша точка с хот-догами куда-то пропала, залог не будет возвращён!',
        no_more = 'У вас больше нет %{value}',
        deposit_notreturned = 'У вас не было точки с хот-догами',
        no_dogs = 'У вас нет хот-догов',
    },
    success = {
        deposit = 'Вы оплатили залог $%{deposit}!',
        deposit_returned = 'Ваш залог $%{deposit} возвращён!',
        sold_hotdogs = '%{value} x хот-дог(ов) продано за $%{value2}',
        made_hotdog = 'Вы приготовили %{value} хот-догов',
        made_luck_hotdog = 'Вы приготовили %{value} x %{value2} хот-догов',
    },
    info = {
        command = "Удалить точку (только админ)",
        blip_name = 'Точка с хот-догами',
        start_working = '[E] Начать работу',
        start_work = 'Начать работу',
        stop_working = '[E] Закончить работу',
        stop_work = 'Закончить работу',
        grab_stall = '[~g~G~s~] Взять точку',
        drop_stall = '[~g~G~s~] Поставить точку',
        grab = 'Взять точку',
        prepare = 'Приготовить хот-дог',
        toggle_sell = 'Включить продажу',
        selling_prep = '[~g~E~s~] Приготовить хот-дог [Продажа: ~g~Идёт~w~]',
        not_selling = '[~g~E~s~] Приготовить хот-дог [Продажа: ~r~Не идёт~w~]',
        sell_dogs = '[~g~7~s~] Продать %{value} x хот-догов за $%{value2} / [~g~8~s~] Отказать',
        sell_dogs_target = 'Продать %{value} x хот-догов за $%{value2}',
        admin_removed = "Точка с хот-догами удалена",
        label_a = "Идеально (A)",
        label_b = "Редкий (B)",
        label_c = "Обычный (C)"
    },
    keymapping = {
        gkey = 'Отпустить точку с хот-догами',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
