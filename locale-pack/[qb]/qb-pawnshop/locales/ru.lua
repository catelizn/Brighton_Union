local Translations = {
    error = {
        negative = 'Пытаетесь продать отрицательное количество?',
        no_melt = 'Вы не дали мне ничего на переплавку...',
        no_items = 'Недостаточно предметов',
        inventory_full = 'Инвентарь слишком заполнен, чтобы получить все предметы. В следующий раз освободите место. Потеряно: %{value}'
    },
    success = {
        sold = 'Вы продали %{value} x %{value2} за $%{value3}',
        items_received = 'Вы получили %{value} x %{value2}',
    },
    info = {
        title = 'Ломбард',
        subject = 'Переплавка предметов',
        message = 'Мы закончили переплавлять ваши предметы. Можете забрать их в любое время.',
        open_pawn = 'Открыть ломбард',
        sell = 'Продать предметы',
        sell_pawn = 'Продать предметы в ломбард',
        melt = 'Переплавить предметы',
        melt_pawn = 'Открыть цех переплавки',
        melt_pickup = 'Забрать переплавленные предметы',
        pawn_closed = 'Ломбард закрыт. Приходите с %{value}:00 до %{value2}:00',
        sell_items = 'Цена продажи $%{value}',
        back = '⬅ Назад',
        melt_item = 'Переплавить %{value}',
        max = 'Максимум %{value}',
        submit = 'Переплавить',
        melt_wait = 'Дайте мне %{value} минут, и я всё переплавлю',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
