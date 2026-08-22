local Translations = {
    afk = {
        will_kick = 'Вы бездействуете и будете исключены через ',
        time_seconds = ' секунд!',
        time_minutes = ' минут(ы)!',
        kick_message = 'Вы были исключены за бездействие'
    },
    wash = {
        in_progress = "Машина моется...",
        wash_vehicle = "[E] Помыть машину",
        wash_vehicle_target = "Помыть машину",
        dirty = "Машина не грязная",
        cancel = "Мойка отменена..."
    },
    consumables = {
        eat_progress = "Едим...",
        drink_progress = "Пьём...",
        liqour_progress = "Пьём алкоголь...",
        coke_progress = "Вдыхаем...",
        crack_progress = "Курим крэк...",
        ecstasy_progress = "Принимаем таблетку",
        healing_progress = "Лечение",
        meth_progress = "Курим мет...",
        joint_progress = "Поджигаем косяк...",
        use_parachute_progress = "Надеваем парашют...",
        pack_parachute_progress = "Складываем парашют...",
        no_parachute = "У вас нет парашюта!",
        armor_full = "У вас уже достаточно брони!",
        armor_empty = "На вас нет бронежилета...",
        armor_progress = "Надеваем бронежилет...",
        heavy_armor_progress = "Надеваем тяжёлый бронежилет...",
        remove_armor_progress = "Снимаем бронежилет...",
        canceled = "Отменено..."
    },
    cruise = {
        unavailable = "Круиз-контроль недоступен",
        activated = "Круиз-контроль включён",
        deactivated = "Круиз-контроль выключен",
        not_Enough_Fuel = "Недостаточно топлива"
    },
    editor = {
        started = "Запись начата!",
        save = "Запись сохранена!",
        delete = "Запись удалена!",
        editor = "До встречи!"
    },
    firework = {
        place_progress = "Устанавливаем фейерверк...",
        canceled = "Отменено...",
        time_left = "Запуск фейерверка через "
    },
    seatbelt = {
        use_harness_progress = "Пристёгиваем гоночный ремень",
        remove_harness_progress = "Отстёгиваем гоночный ремень",
        no_car = "Вы не в машине."
    },
    teleport = {
        teleport_default = 'Воспользоваться лифтом'
    },
    pushcar = {
        stop_push = "[E] Перестать толкать",
        notDamaged = "Машина недостаточно повреждена, чтобы её толкать!",
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
