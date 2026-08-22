local Translations = {
    error = {
        no_people_nearby = "Рядом нет игроков",
        no_vehicle_found = "Машина не найдена",
        extra_deactivated = "Элемент %{extra} выключен",
        extra_not_present = "Элемента %{extra} нет на этой машине",
        not_driver = "Вы не водитель этой машины",
        vehicle_driving_fast = "Эта машина едет слишком быстро",
        seat_occupied = "Это место занято",
        race_harness_on = "На вас гоночный ремень, вы не можете пересесть",
        obj_not_found = "Не удалось создать запрошенный объект",
        not_near_ambulance = "Вы не рядом со скорой помощью",
        far_away = "Вы слишком далеко",
        stretcher_in_use = "Эти носилки уже заняты",
        not_kidnapped = "Вы не похищали этого человека",
        trunk_closed = "Багажник закрыт",
        cant_enter_trunk = "Вы не можете залезть в этот багажник",
        already_in_trunk = "Вы уже в багажнике",
        someone_in_trunk = "В багажнике уже кто-то есть"
    },
    progress = {
        flipping_car = "Переворачиваем машину.."
    },
    success = {
        extra_activated = "Элемент %{extra} включён",
        entered_trunk = "Вы в багажнике"
    },
    info = {
        no_variants = "Похоже, для этого нет вариантов",
        wrong_ped = "Эта модель персонажа не поддерживает данную опцию",
        nothing_to_remove = "Похоже, вам нечего снимать",
        already_wearing = "Вы уже носите это",
        switched_seats = "Вы пересели на место %{seat}"
    },
    general = {
        command_description = "Открыть радиальное меню",
        push_stretcher_button = "[E] - Толкать носилки",
        stop_pushing_stretcher_button = "~g~E~w~ - Перестать толкать",
        lay_stretcher_button = "[G] - Лечь на носилки",
        push_position_drawtext = "Толкать здесь",
        get_off_stretcher_button = "[G] - Встать с носилок",
        get_out_trunk_button = "[E] Вылезти из багажника",
        close_trunk_button = "[G] Закрыть багажник",
        open_trunk_button = "[G] Открыть багажник",
        getintrunk_command_desc = "Залезть в багажник",
        putintrunk_command_desc = "Посадить игрока в багажник"
    },
    options = {
        emergency_button = "Тревожная кнопка",
        driver_seat = "Место водителя",
        passenger_seat = "Пассажирское место",
        other_seats = "Другое место",
        rear_left_seat = "Заднее левое место",
        rear_right_seat = "Заднее правое место"
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
