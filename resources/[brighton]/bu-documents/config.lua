Config = Config or {}

-- Фотоателье: отдельное помещение в городе (вход через дверь)
Config.Studio = {
    door = vector4(84.0, -1390.0, 29.3, 80.0),
    interiorOffsetZ = 400,          -- интерьер создаётся ниже уровня карты
    exitOffset = vector3(-0.64, -5.07, 1.02), -- точка выхода внутри shell_store2
    npcModel = 'a_m_y_photographer_01',
    blip = { sprite = 280, color = 2, scale = 0.7, name = 'Фотоателье' }
}

Config.TargetLabel = 'Фотоателье'
Config.ExitLabel = 'Выйти'
Config.PhotoLabel = 'Сделать фото на документы'

Config.DocumentsKey = 'P'

