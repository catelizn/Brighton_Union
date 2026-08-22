local Translations = {
    error = {
        to_far_from_door = 'Вы слишком далеко от дверного звонка',
        nobody_home = 'Дома никого нет..',
        nobody_at_door = 'За дверью никого нет...'
    },
    success = {
        receive_apart = 'Вы получили квартиру',
        changed_apart = 'Вы переехали в другую квартиру',
    },
    info = {
        at_the_door = 'Кто-то у двери!',
    },
    text = {
        options = '[E] Меню квартиры',
        enter = 'Войти в квартиру',
        ring_doorbell = 'Позвонить в дверь',
        logout = 'Выйти из персонажа',
        change_outfit = 'Сменить наряд',
        open_stash = 'Открыть хранилище',
        move_here = 'Переехать сюда',
        open_door = 'Открыть дверь',
        leave = 'Покинуть квартиру',
        close_menu = '⬅ Закрыть меню',
        tennants = 'Жильцы',
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
