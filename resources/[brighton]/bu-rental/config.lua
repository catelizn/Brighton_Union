Config = Config or {}

-- Прокат транспорта у выхода из терминала аэропорта Лос-Сантос: Steve Carter
Config.Stand = {
    model = 'a_m_y_business_03',
    npcName = 'Steve Carter',
    coords = vector4(-1030.42, -2732.28, 13.76, 102.67),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
    blip = {
        sprite = 225,
        color = 2,
        scale = 0.7,
        name = 'Прокат транспорта'
    },
    spawn = vector4(-1024.41, -2728.48, 13.67, 237.12),
    returnDistance = 25.0
}

Config.TargetLabel = 'Steve Carter (АРЕНДА)'
Config.ReturnLabel = 'Вернуть транспорт'

-- Аренда от 1 до 3 часов, цена умножается на срок
Config.MaxRentHours = 3

Config.Vehicles = {
    { model = 'bmx',        label = 'Велосипед BMX',    price = 50,   requiresLicense = false },
    { model = 'faggio',     label = 'Скутер Faggio',    price = 150,  requiresLicense = false },
    { model = 'asea',       label = 'Седан Asea',       price = 500,  requiresLicense = true },
    { model = 'washington', label = 'Седан Washington', price = 1000, requiresLicense = true }
}
