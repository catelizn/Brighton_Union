local Translations = {
    error = {
        to_far_from_door = 'Ты слишком далеко от дверного звонка',
        nobody_home = 'Дома никого нет..',
        nobody_at_door = 'За дверью никого нет...'
    },
    success = {
        receive_apart = 'Ты получил квартиру',
        changed_apart = 'Ты переехал в другую квартиру',
    },
    info = {
        at_the_door = 'Кто-то стоит у двери!',
    },
    text = {
        options = '[E] Квартира',
        enter = 'Войти в квартиру',
        ring_doorbell = 'Позвонить в звонок',
        logout = 'Выйти из персонажа',
        change_outfit = 'Сменить одежду',
        open_stash = 'Открыть хранилище',
        move_here = 'Переехать сюда',
        open_door = 'Открыть дверь',
        leave = 'Покинуть квартиру',
        close_menu = 'Закрыть меню',
        tennants = 'Жильцы',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})