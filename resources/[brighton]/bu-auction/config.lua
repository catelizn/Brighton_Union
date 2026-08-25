Config = Config or {}

Config.Hall = {
    door = vector4(291.5, -1078.7, 29.4, 250.0),
    interiorOffsetZ = 500,
    exitOffset = vector3(0.0, -8.0, 1.0),
    blip = { sprite = 605, color = 2, scale = 0.8, name = 'Аукционный дом' }
}

Config.TargetLabel = 'Аукционный дом'
Config.ExitLabel = 'Выйти'
Config.NpcModel = 'a_m_y_business_01'

Config.Commission = 0.10
Config.DefaultDuration = 300 -- секунд аукциона по умолчанию
Config.MinBidStep = 0.10     -- шаг ставки: +10% от текущей
Config.AntisnipeSeconds = 60 -- если до конца меньше минуты, ставка продлевает торги
