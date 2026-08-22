local Translations = {
    error = {
        canceled = 'Отменено',
        max_ammo = 'Максимум патронов',
        no_weapon = 'У вас нет оружия.',
        wrong_ammo = 'Не тот тип патронов.',
        no_support_attachment = 'Это оружие не поддерживает данный обвес.',
        no_weapon_in_hand = 'У вас нет оружия в руках.',
        weapon_broken = 'Это оружие сломано и не может использоваться.',
        no_damage_on_weapon = 'Это оружие не повреждено..',
        weapon_broken_need_repair = 'Ваше оружие сломано, почините его перед использованием.',
        attachment_already_on_weapon = 'На вашем оружии уже есть %{value}.'
    },
    success = {
        reloaded = 'Перезаряжено'
    },
    info = {
        loading_bullets = 'Заряжаем патроны',
        repairshop_not_usable = 'Оружейная мастерская сейчас ~r~НЕ~w~ работает.',
        weapon_will_repair = 'Ваше оружие будет отремонтировано.',
        take_weapon_back = '[E] - Забрать оружие',
        repair_weapon_price = '[E] Починить оружие, ~g~$%{value}~w~',
        removed_attachment = 'Вы сняли %{value} с оружия!',
        hp_of_weapon = 'Прочность вашего оружия'
    },
    mail = {
        sender = 'Tyrone',
        subject = 'Ремонт',
        message = 'Ваш %{value} отремонтирован, можете забрать его на месте. <br><br> Peace out madafaka'
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
