local Translations = {
    notify = {
        ydhk = 'У вас нет ключей от этой машины.',
        nonear = 'Рядом нет никого, кому можно передать ключи',
        vlock = 'Машина заперта!',
        vunlock = 'Машина открыта!',
        vlockpick = 'Вам удалось вскрыть дверной замок!',
        fvlockpick = 'Вам не удалось взломать замок, вы расстроены.',
        vgkeys = 'Вы передали ключи.',
        vgetkeys = 'Вы получили ключи от машины!',
        fpid = 'Укажите ID игрока и номерной знак',
        cjackfail = 'Угон не удался!',
        vehclose = 'Рядом нет машины!',
    },
    progress = {
        takekeys = 'Забираем ключи...',
        hskeys = 'Ищем ключи от машины...',
        acjack = 'Пытаемся угнать машину...',
    },
    info = {
        skeys = '~g~[H]~w~ - Искать ключи',
        tlock = 'Открыть/запереть машину',
        palert = 'Идёт угон машины. Тип: ',
        engine = 'Завести/заглушить двигатель',
    },
    addcom = {
        givekeys = 'Передать ключи игроку. Без ID — ближайшему человеку или всем в машине.',
        givekeys_id = 'id',
        givekeys_id_help = 'ID игрока',
        addkeys = 'Добавить ключи от машины игроку.',
        addkeys_id = 'id',
        addkeys_id_help = 'ID игрока',
        addkeys_plate = 'номер',
        addkeys_plate_help = 'Номерной знак',
        rkeys = 'Забрать ключи от машины у игрока.',
        rkeys_id = 'id',
        rkeys_id_help = 'ID игрока',
        rkeys_plate = 'номер',
        rkeys_plate_help = 'Номерной знак',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
