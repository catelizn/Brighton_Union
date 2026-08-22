local Translations = {
    success = {
        withdraw = 'Снятие прошло успешно',
        deposit = 'Пополнение прошло успешно',
        transfer = 'Перевод прошёл успешно',
        account = 'Счёт создан',
        rename = 'Счёт переименован',
        delete = 'Счёт удалён',
        userAdd = 'Пользователь добавлен',
        userRemove = 'Пользователь удалён',
        card = 'Карта создана',
        give = 'Выдано наличных: $%s',
        receive = 'Получено наличных: $%s',
    },
    error = {
        error = 'Произошла ошибка',
        access = 'Нет доступа',
        account = 'Счёт не найден',
        accounts = 'Достигнут лимит счетов',
        user = 'Пользователь уже добавлен',
        noUser = 'Пользователь не найден',
        money = 'Недостаточно денег',
        pin = 'Неверный PIN',
        card = 'Банковская карта не найдена',
        amount = 'Неверная сумма',
        toofar = 'Вы слишком далеко',
    },
    progress = {
        atm = 'Подключаемся к банкомату',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
