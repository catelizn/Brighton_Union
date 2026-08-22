local Translations = {
    progress = {
        refueling = 'Заправляем...',
    },
    success = {
        refueled = 'Машина заправлена',
    },
    error = {
        no_money = 'У вас недостаточно денег',
        no_vehicle = 'Рядом нет машины',
        no_vehicles = 'Рядом нет машин',
        no_jerrycan = 'У вас нет канистры',
        vehicle_full = 'Машина уже полностью заправлена',
        no_fuel_can = 'В канистре нет топлива',
        no_nozzle = 'Рядом нет машины с прикреплённым пистолетом',
        too_far = 'Вы слишком далеко от колонки, пистолет возвращён',
        wrong_side = 'Бак машины с другой стороны',
    },
    target = {
        put_fuel = 'Залить топливо',
        get_nozzle = 'Взять пистолет',
        buy_jerrycan = 'Купить канистру $%{price}',
        refill_jerrycan = 'Заправить канистру $%{price}',
        refill_fuel = 'Заправить машину',
        nozzle_put = 'Прикрепить пистолет',
        nozzle_remove = 'Открепить пистолет',
        return_nozzle = 'Вернуть пистолет',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
