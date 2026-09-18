Config = Config or {}

-- Питомцы: доступные модели и цена
Config.Pets = {
    { model = 'a_c_cat_01',  label = 'Кот',   price = 5000 },
    { model = 'a_c_husky',   label = 'Хаски', price = 7500 },
    { model = 'a_c_poodle',  label = 'Пудель', price = 8000 },
    { model = 'a_c_rottweiler', label = 'Ротвейлер', price = 10000 }
}

Config.PetDropoff = vector3(100.0, -1540.0, 30.0) -- зоомагазин (примерная точка)
