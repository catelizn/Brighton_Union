local Translations = {
    error = {
        process_canceled = "Процесс отменён",
        plant_has_died = "Растение погибло. Нажмите ~r~ E ~w~, чтобы убрать его.",
        cant_place_here = "Здесь нельзя посадить",
        not_safe_here = "Здесь небезопасно, попробуйте у себя дома",
        not_need_nutrition = "Растению не нужна подкормка",
        this_plant_no_longer_exists = "Этого растения больше не существует?",
        house_not_found = "Дом не найден",
        you_dont_have_enough_resealable_bags = "У вас недостаточно пакетов с застёжкой",
    },
    text = {
        sort = 'Сорт:',
        harvest_plant = 'Нажмите ~g~ E ~w~, чтобы собрать урожай.',
        nutrition = "Питание:",
        health = "Здоровье:",
        progress = "Прогресс:",
        harvesting_plant = "Собираем урожай",
        planting = "Сажаем",
        feeding_plant = "Подкармливаем растение",
        the_plant_has_been_harvested = "Урожай собран",
        removing_the_plant = "Убираем растение",
        stage = "Текущая стадия:",
        highestStage = "Стадия сбора:",
    },
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
