Config = Config or {}

-- Прокат транспорта на верхнем ярусе аэропорта Лос-Сантос: Steve Carter
Config.Stand = {
    model = 'a_m_y_business_03',
    npcName = 'Steve Carter',
    coords = vector4(-1043.0, -2730.0, 28.6, 150.0),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
    blip = {
        sprite = 225,
        color = 2,
        scale = 0.7,
        name = 'Прокат транспорта'
    },
    spawn = vector4(-1041.0, -2726.0, 28.6, 90.0),
    returnPoint = vector3(-1040.0, -2728.0, 28.6),
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
