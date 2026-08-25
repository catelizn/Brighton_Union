Config = Config or {}

-- Мафии воюют за бизнесы: доход с каждого — в казну на Payday (:00 каждый час)
Config.Mafias = {
    italian_mafia = {
        label = 'Итальянская мафия',
        joinLabel = 'Вступить в итальянскую мафию',
        coords = vector4(935.0, 50.0, 81.0, 180.0),
        model = 'g_m_y_italydoom_01',
        color = 1
    },
    russian_mafia = {
        label = 'Русская мафия',
        joinLabel = 'Вступить в русскую мафию',
        coords = vector4(-1330.0, -1100.0, 7.0, 180.0),
        model = 'g_m_y_slavboss_01',
        color = 3
    },
    mexican_mafia = {
        label = 'Мексиканская мафия',
        joinLabel = 'Вступить в мексиканскую мафию',
        coords = vector4(600.0, -2300.0, 22.0, 180.0),
        model = 'g_m_y_mexboss_01',
        color = 5
    },
    yakuza = {
        label = 'Японская мафия',
        joinLabel = 'Вступить в якудзу',
        coords = vector4(500.0, -3100.0, 5.0, 180.0),
        model = 'g_m_y_yakuza_01',
        color = 4
    }
}

-- Бизнесы, за которые воюют мафии (ключи совпадают с bu-properties).
-- value — доход в казну мафии на каждый Payday. Дорогие бизнесы приносят больше.
Config.Businesses = {
    { key = 'lsc_1',    label = 'Автомастерская LSC (город)', coords = vector3(731.81, -1088.83, 22.17),  value = 350 },
    { key = 'lsc_2',    label = 'Автомастерская LSC (Бёртон)', coords = vector3(-337.79, -136.93, 39.01), value = 350 },
    { key = 'lsc_3',    label = 'Автомастерская LSC (аэропорт)', coords = vector3(-1155.45, -2007.58, 13.18), value = 350 },
    { key = 'lsc_4',    label = 'Автомастерская LSC (Грейпсид)', coords = vector3(1174.82, 2640.72, 37.79), value = 350 },
    { key = 'shop_247', label = 'Магазин 24/7', coords = vector3(25.0, -1346.6, 29.5),  value = 200 },
    { key = 'carwash',  label = 'Автомойка', coords = vector3(55.7, -1391.0, 29.4), value = 150 },
    { key = 'petrol',   label = 'Заправка LTD', coords = vector3(-47.02, -1758.23, 29.42), value = 250 }
}

-- Война за бизнес: удержание точки, чужой участник мафии срывает
Config.WarSeconds = 60
Config.MinWarRank = 2           -- «Капо» и выше
Config.WarCooldown = 300        -- секунд между попытками одной мафии

-- Команды
Config.QuitCommand = 'quitmafia'
Config.TreasuryCommand = 'mafiamoney'
Config.WithdrawCommand = 'mwithdraw'
