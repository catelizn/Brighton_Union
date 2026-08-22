local Translations = {
    success = {
        success_message = "Успешно",
        fuses_are_blown = "Предохранители перегорели",
        door_has_opened = "Дверь открылась"
    },
    error = {
        cancel_message = "Отменено",
        safe_too_strong = "Похоже, замок сейфа слишком прочный...",
        missing_item = "Вам не хватает предмета...",
        bank_already_open = "Банк уже открыт...",
        minimum_police_required = "Требуется минимум %{police} полицейских",
        security_lock_active = "Защита активна, открыть дверь сейчас невозможно",
        wrong_type = "%{receiver} получил неверный тип для аргумента '%{argument}'\nполученный тип: %{receivedType}\nполученное значение: %{receivedValue}\n ожидаемый тип: %{expected}",
        fuses_already_blown = "Предохранители уже перегорели...",
        event_trigger_wrong = "%{event}%{extraInfo} сработал, когда условия не были выполнены, source: %{source}",
        missing_ignition_source = "У вас нет источника огня"
    },
    general = {
        breaking_open_safe = "Вскрываем сейф...",
        connecting_hacking_device = "Подключаем устройство взлома...",
        fleeca_robbery_alert = "Попытка ограбления банка Fleeca",
        paleto_robbery_alert = "Попытка ограбления банка Blain County Savings",
        pacific_robbery_alert = "Попытка ограбления Pacific Standard Bank",
        break_safe_open_option_target = "Вскрыть сейф",
        break_safe_open_option_drawtext = "[E] Вскрыть сейф",
        validating_bankcard = "Проверяем карту...",
        thermite_detonating_in_seconds = "Термит сработает через %{time} секунд(ы)",
        bank_robbery_police_call = "10-90: Ограбление банка"
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
