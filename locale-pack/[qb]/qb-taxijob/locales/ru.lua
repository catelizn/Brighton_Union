local Translations = {
    error = {
        ['already_mission'] = 'Вы уже выполняете NPC-задание',
        ['not_in_taxi'] = 'Вы не в такси',
        ['missing_meter'] = 'В этой машине нет таксометра',
        ['no_vehicle'] = "Вы не в машине",
        ['not_active_meter'] = 'Таксометр не активен',
        ['ride_canceled'] = 'Вы слишком часто попадали в аварии, поездка отменена!',
        ['broken_taxi'] = 'Такси нужно отремонтировать перед продолжением работы!',
        ['crash_warning'] = 'Если вы попадёте в аварию ещё %d %s, клиент остановит поездку и вы не получите оплату!',
        ['time'] = 'раз',
        ['times'] = 'раза',
    },
    success = {
        ['mission_cancelled'] = 'Задание успешно отменено',
    },
    info = {
        ['person_was_dropped_off'] = 'Пассажир высажен!',
        ['npc_on_gps'] = 'NPC отмечен на вашем GPS',
        ['go_to_location'] = 'Отвезите NPC в указанное место',
        ['vehicle_parking'] = '[E] Парковка машин',
        ['job_vehicles'] = '[E] Служебный транспорт',
        ['drop_off_npc'] = '[E] Высадить NPC',
        ['call_npc'] = '[E] Вызвать NPC',
        ['blip_name'] = 'Downtown Cab',
        ['taxi_label_1'] = 'Обычное такси',
        ['no_spawn_point'] = 'Не удалось найти место для такси',
        ['taxi_returned'] = 'Такси припарковано',
        ['on_duty'] = '[E] - Заступить на смену',
        ['off_duty'] = '[E] - Уйти со смены',
        ['tip_received'] = 'Вы получили чаевые $%d за аккуратную езду',
        ['tip_not_received'] = 'Старайтесь не попадать в аварии, если хотите получать чаевые',
    },
    menu = {
        ['taxi_menu_header'] = 'Машины такси',
        ['close_menu'] = '⬅ Закрыть меню',
        ['boss_menu'] = 'Меню босса'
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
