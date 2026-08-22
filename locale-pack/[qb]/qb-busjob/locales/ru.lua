local Translations = {
    error = {
        already_driving_bus = 'Вы уже за рулём автобуса',
        not_in_bus = 'Вы не в автобусе',
        one_bus_active = 'Одновременно можно использовать только один автобус',
        drop_off_passengers = 'Высадите пассажиров, прежде чем закончить работу',
        exploit = "Попытка эксплуатации уязвимости"
    },
    success = {
        dropped_off = 'Пассажир высажен',
    },
    info = {
        bus = 'Обычный автобус',
        goto_busstop = 'Поезжайте к автобусной остановке',
        busstop_text = '[E] Автобусная остановка',
        bus_plate = 'BUS',
        bus_depot = 'Автобусное депо',
        bus_stop_work = '[E] Закончить работу',
        bus_job_vehicles = '[E] Служебный транспорт'
    },
    menu = {
        bus_header = 'Автобусы',
        bus_close = '⬅ Закрыть меню'
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
