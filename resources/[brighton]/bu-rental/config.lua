Config = Config or {}

-- Прокат транспорта в аэропорту Лос-Сантоса: Jack Carter
Config.Stand = {
    model = 'a_m_y_business_03',
    npcName = 'Steve Carter',
    coords = vector4(-1026.0, -2728.0, 13.8, 240.0),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
    blip = {
        sprite = 225,
        color = 2,
        scale = 0.7,
        name = 'Прокат транспорта'
    },
    spawn = vector4(-1014.0, -2708.0, 13.8, 150.0),
    returnDistance = 25.0
}

Config.TargetLabel = 'Прокат транспорта'
Config.ReturnLabel = 'Вернуть транспорт'

-- Аренда от 1 до 3 часов, цена умножается на срок
Config.MaxRentHours = 3

Config.Vehicles = {
    { model = 'bmx',        label = 'Велосипед BMX',    price = 50,   requiresLicense = false },
    { model = 'faggio',     label = 'Скутер Faggio',    price = 150,  requiresLicense = false },
    { model = 'asea',       label = 'Седан Asea',       price = 500,  requiresLicense = true },
    { model = 'washington', label = 'Седан Washington', price = 1000, requiresLicense = true }
}
