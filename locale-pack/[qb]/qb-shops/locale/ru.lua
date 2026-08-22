local Translations = {
    info = {
        open_shop = '[E] Магазин',
        deliver_e = '~g~E~w~ - Доставить товар',
        deliver = 'Доставить товар',
    },
    error = {
        missing_license = 'Для некоторых товаров нужна лицензия %s',
        no_deposit = 'Требуется залог $%{value}',
        cancelled = 'Отменено',
        vehicle_not_correct = 'Это не коммерческий транспорт!',
        no_driver = 'Вы должны быть за рулём, чтобы сделать это..',
        no_work_done = "Вы ещё не выполнили ни одного заказа..",
        backdoors_not_open = "Задние двери машины не открыты",
        get_out_vehicle = 'Нужно выйти из машины, чтобы выполнить это действие',
        too_far_from_trunk = 'Нужно взять коробки из багажника вашей машины',
        too_far_from_delivery = 'Нужно подойти ближе к точке доставки'
    },
    success = {
        dealer_verify = 'Дилер проверяет вашу лицензию',
        paid_with_cash = 'Залог $%{value} оплачен наличными',
        paid_with_bank = 'Залог $%{value} оплачен с банковского счёта',
        refund_to_cash = 'Залог $%{value} возвращён наличными',
        you_earned = 'Вы заработали $%{value}',
        payslip_time = 'Вы объехали все магазины.. Время получить зарплату!',
    },
    mission = {
        store_reached = 'Вы у магазина: возьмите коробку из багажника по [E] и доставьте её к маркеру',
        take_box = 'Взять коробку с товаром',
        deliver_box = 'Доставить коробку с товаром',
        another_box = 'Взять ещё одну коробку с товаром',
        goto_next_point = 'Вы доставили все товары, следующая точка',
        return_to_station = 'Вы доставили все товары, возвращайтесь на станцию',
        job_completed = 'Вы завершили свой маршрут'
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
