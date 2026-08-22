local Translations = {
    menus = {
        header = 'Меню крафта',
        pickupworkBench = 'Забрать верстак',
        entercraftAmount = 'Введите количество:',
    },
    notifications = {
        pickupBench = 'Вы забрали верстак.',
        invalidAmount = 'Введено неверное количество',
        invalidInput = 'Неверный ввод',
        notenoughMaterials = "У вас недостаточно материалов!",
        craftingCancelled = 'Крафт отменён',
        tablePlace = 'Ваш верстак установлен',
        craftMessage = 'Вы скрафтили: %s',
        xpGain = 'Вы получили %d опыта в %s',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
