local Translations = {
    error = {
        not_your_vehicle = 'Это не ваша машина..',
        vehicle_does_not_exist = 'Машина не существует',
        not_enough_money = 'У вас недостаточно денег',
        finish_payments = 'Сначала выплатите кредит за эту машину, прежде чем продавать её..',
        no_space_on_lot = 'На площадке нет места для вашей машины!',
        not_in_veh = 'Вы не в машине!',
        not_for_sale = 'Эта машина НЕ продаётся!',
    },
    menu = {
        view_contract = 'Посмотреть договор',
        view_contract_int = '[E] Посмотреть договор',
        sell_vehicle = 'Продать машину',
        sell_vehicle_help = 'Продать машину другому жителю!',
        sell_back = 'Продать машину обратно!',
        sell_back_help = 'Продать машину дилеру по сниженной цене!',
        interaction = '[E] Продать машину',
    },
    success = {
        sold_car_for_price = 'Вы продали машину за $%{value}',
        car_up_for_sale = 'Ваша машина выставлена на продажу! Цена - $%{value}',
        vehicle_bought = 'Машина куплена',
    },
    info = {
        confirm_cancel = '~g~Y~w~ - Подтвердить / ~r~N~w~ - Отмена ~g~',
        vehicle_returned = 'Ваша машина возвращена',
        used_vehicle_lot = 'Площадка подержанных машин',
        sell_vehicle_to_dealer = '[~g~E~w~] - Продать машину дилеру за ~g~$%{value}',
        view_contract = '[~g~E~w~] - Посмотреть договор на машину',
        cancel_sale = '[~r~G~w~] - Отменить продажу машины',
        model_price = '%{value}, Цена: ~g~$%{value2}',
        are_you_sure = 'Вы уверены, что больше не хотите продавать машину?',
        yes_no = '[~g~7~w~] - Да | [~r~8~w~] - Нет',
        place_vehicle_for_sale = '[~g~E~w~] - Выставить машину на продажу владельцем',
    },
    charinfo = {
        firstname = 'не',
        lastname = 'известно',
        account = 'Счёт неизвестен..',
        phone = 'номер телефона неизвестен..',
    },
    mail = {
        sender = 'Larrys RV Sales',
        subject = 'Вы продали машину!',
        message = 'Вы заработали $%{value} на продаже %{value2}.',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
