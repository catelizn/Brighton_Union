local Translations = {
    error = {
        ["canceled"] = "Отменено",
        ["911_chatmessage"] = "СООБЩЕНИЕ 911",
        ["take_off"] = "/divingsuit — снять гидрокостюм",
        ["not_wearing"] = "На вас нет снаряжения для дайвинга ..",
        ["no_coral"] = "У вас нет кораллов на продажу..",
        ["not_standing_up"] = "Нужно стоять, чтобы надеть снаряжение для дайвинга",
        ["need_otube"] = "Вам нужна кислородная трубка, чтобы заправить пустое снаряжение",
        ["oxygenlevel"] = 'уровень снаряжения %{oxygenlevel}, должен быть 0%'
    },
    success = {
        ["took_out"] = "Вы сняли гидрокостюм",
        ["tube_filled"] = "Трубка успешно заправлена"
    },
    info = {
        ["collecting_coral"] = "Собираем кораллы",
        ["diving_area"] = "Зона дайвинга",
        ["collect_coral"] = "Собрать кораллы",
        ["collect_coral_dt"] = "[E] - Собрать кораллы",
        ["checking_pockets"] = "Проверяем карманы для продажи кораллов",
        ["sell_coral"] = "Продать кораллы",
        ["sell_coral_dt"] = "[E] - Продать кораллы",
        ["blip_text"] = "911 - Место погружения",
        ["put_suit"] = "Надеть гидрокостюм",
        ["pullout_suit"] = "Снимаем гидрокостюм ..",
        ["cop_msg"] = "Эти кораллы могут быть крадеными",
        ["cop_title"] = "Нелегальный дайвинг",
        ["command_diving"] = "Снять гидрокостюм",
    },
    warning = {
        ["oxygen_one_minute"] = "Воздуха осталось меньше, чем на 1 минуту",
        ["oxygen_running_out"] = "В вашем снаряжении заканчивается воздух",
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
