local Translations = {
    error = {
        finish_work = "Сначала завершите всю работу",
        vehicle_not_correct = "Это не та машина",
        failed = "У вас не получилось",
        not_towing_vehicle = "Вы должны быть в своём эвакуаторе",
        too_far_away = "Вы слишком далеко",
        no_work_done = "Вы ещё не выполнили работу",
        no_deposit = "Требуется залог $%{value}",
    },
    success = {
        paid_with_cash = "Залог $%{value} оплачен наличными",
        paid_with_bank = "Залог $%{value} оплачен с банковского счёта",
        refund_to_cash = "Залог $%{value} возвращён наличными",
        you_earned = "Вы заработали $%{value}",
    },
    menu = {
        header = "Доступные эвакуаторы",
        close_menu = "⬅ Закрыть меню",
    },
    mission = {
        delivered_vehicle = "Вы доставили машину",
        get_new_vehicle = "Можно забрать новую машину",
        towing_vehicle = "Поднимаем машину...",
        goto_depot = "Отвезите машину в депо Hayes",
        vehicle_towed = "Машина погружена",
        untowing_vehicle = "Снимаем машину",
        vehicle_takenoff = "Машина снята",
    },
    info = {
        tow = "Поставьте машину на платформу эвакуатора",
        toggle_npc = "Переключить NPC-работу",
        skick = "Попытка эксплуатации уязвимости",
    },
    label = {
        payslip = "Зарплата",
        vehicle = "Машина",
        npcz = "Зона NPC",
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
