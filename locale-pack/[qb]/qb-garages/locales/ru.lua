local Translations = {
    error = {
        no_vehicles = 'В этом месте нет машин!',
        not_depot = 'Ваша машина не на штрафстоянке',
        not_owned = 'Эту машину нельзя поставить',
        not_correct_type = 'Такой тип транспорта нельзя хранить здесь',
        not_enough = 'Недостаточно денег',
        no_garage = 'Нет',
        vehicle_occupied = 'Нельзя поставить машину, если она не пустая',
        vehicle_not_tracked = 'Не удалось отследить машину',
        no_spawn = 'Место слишком загружено'
    },
    success = {
        vehicle_parked = 'Машина поставлена в гараж',
        vehicle_tracked = 'Машина отслеживается',
    },
    status = {
        out = 'Вне гаража',
        garaged = 'В гараже',
        impound = 'Конфискована полицией',
        house = 'Дом',
    },
    info = {
        car_e = 'E - Гараж',
        sea_e = 'E - Эллинг',
        air_e = 'E - Ангар',
        rig_e = 'E - Стоянка грузовиков',
        depot_e = 'E - Депо',
        house_garage = 'E - Гараж дома',
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
