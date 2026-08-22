local Translations = {
    error = {
        ['missing_something'] = 'Похоже, вам чего-то не хватает...',
        ['not_enough_police'] = 'Недостаточно полиции..',
        ['door_open'] = 'Дверь уже открыта..',
        ['process_cancelled'] = 'Процесс отменён..',
        ['didnt_work'] = 'Не получилось..',
        ['emty_box'] = 'Коробка пуста..',
        ['not_allowed_time'] = "Сейчас нельзя этим заниматься."
    },
    success = {
        ['worked'] = 'Получилось!',
    },
    info = {
        ['palert'] = 'Попытка ограбления дома',
        ['henter'] = '~g~E~w~ - Войти',
        ['hleave'] = '~g~E~w~ - Выйти из дома',
        ['aint'] = '~g~E~w~ - ',
        ['hsearch'] = 'Ищем..',
        ['hsempty'] = 'Пусто..',
    },
    searching = {
        ['search_bcabinet'] = 'Обыскать прикроватную тумбочку',
        ['search_closet'] = 'Обыскать шкаф',
        ['search_chest'] = 'Обыскать сундук',
        ['search_drawer'] = 'Обыскать ящики',
        ['search_cabinet'] = 'Обыскать тумбочку',
        ['search_kcabinet'] = 'Обыскать кухонные шкафы',
        ['search_shelves'] = 'Обыскать полки',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
