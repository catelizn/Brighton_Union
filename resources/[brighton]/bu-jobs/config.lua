Config = Config or {}

-- Прокачка: уровень 0-10, от уровня зависит оплата каждого действия
Config.XpPerLevel = 100
Config.MaxLevel = 10
Config.PayMultipliers = {
    [0] = 1.00, [1] = 1.08, [2] = 1.16, [3] = 1.24, [4] = 1.32,
    [5] = 1.40, [6] = 1.50, [7] = 1.60, [8] = 1.70, [9] = 1.85, [10] = 2.00
}
Config.GatherCooldown = 3
Config.DefaultZoneRadius = 20.0

-- Найм: у каждой работы стоит свой NPC в униформе, устроиться можно только у него
Config.Jobs = {
    taxi = {
        label = 'Такси',
        basePay = 60,
        xp = 20,
        hire = { model = 's_m_m_busdriver_01', coords = vector4(894.88, -179.22, 74.7, 180.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' }
    },
    trucker = {
        label = 'Дальнобойщик',
        basePay = 80,
        xp = 20,
        hire = { model = 's_m_m_trucker_01', coords = vector4(71.0, 129.0, 79.2, 90.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' }
    },
    postman = {
        label = 'Почтальон',
        basePay = 30,
        xp = 25,
        depot = vector3(69.09, 127.68, 79.21),
        hire = { model = 's_m_m_postal_01', coords = vector4(69.09, 127.68, 79.21, 156.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        route = {
            vector3(113.9, -884.6, 29.0),
            vector3(70.4, -985.4, 29.0),
            vector3(121.5, -1093.2, 29.0),
            vector3(173.3, -1206.4, 29.0),
            vector3(259.6, -1204.6, 29.0),
            vector3(320.0, -1094.2, 29.0),
            vector3(383.2, -1138.6, 29.0),
            vector3(300.0, -1243.2, 29.0),
            vector3(180.0, -1320.0, 29.0),
            vector3(90.0, -1200.0, 29.0)
        }
    },
    lumberjack = {
        label = 'Лесоруб',
        item = 'wood',
        basePay = 40,
        xp = 25,
        hire = { model = 's_m_m_lathandy_01', coords = vector4(-560.96, 5253.08, 70.49, 180.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        zones = {
            { coords = vector3(-560.96, 5253.08, 70.49), radius = 35.0, label = 'Рубить дерево' }
        }
    },
    mushroompicker = {
        label = 'Грибник',
        item = 'mushroom',
        basePay = 35,
        xp = 25,
        hire = { model = 'a_m_m_farmer_01', coords = vector4(-1645.0, 5310.0, 18.0, 180.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        zones = {
            { coords = vector3(-1645.0, 5310.0, 18.0), radius = 50.0, label = 'Собирать грибы' }
        }
    },
    miner = {
        label = 'Шахтёр',
        item = 'ore',
        basePay = 60,
        xp = 25,
        hire = { model = 's_m_m_miner_01', coords = vector4(2957.0, 2748.0, 44.0, 180.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        zones = {
            { coords = vector3(2957.0, 2748.0, 44.0), radius = 45.0, label = 'Добывать руду' }
        }
    },
    oilworker = {
        label = 'Нефтяник',
        item = 'oil',
        basePay = 70,
        xp = 25,
        hire = { model = 's_m_m_dockwork_01', coords = vector4(2420.0, 3138.0, 48.0, 180.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        zones = {
            { coords = vector3(2420.0, 3138.0, 48.0), radius = 45.0, label = 'Качать нефть' }
        }
    },
    butcher = {
        label = 'Мясник',
        item = 'raw_meat',
        basePay = 50,
        xp = 25,
        hire = { model = 's_m_m_linecook', coords = vector4(1009.0, -2330.0, 30.0, 180.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        zones = {
            { coords = vector3(1009.0, -2330.0, 30.0), radius = 25.0, label = 'Разделать мясо' }
        }
    },
    fisherman = {
        label = 'Рыбак',
        item = 'fish',
        basePay = 45,
        xp = 25,
        license = 'fishing_license',
        licenseLabel = 'Лицензия на рыбалку (мэрия)',
        hire = { model = 'a_m_y_beach_01', coords = vector4(-1593.0, -1114.0, 1.5, 180.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        zones = {
            { coords = vector3(-1593.0, -1114.0, 1.5), radius = 25.0, label = 'Ловить рыбу' },
            { coords = vector3(-3240.0, 980.0, 8.0), radius = 25.0, label = 'Ловить рыбу' }
        }
    },
    hunter = {
        label = 'Охотник',
        basePay = 90,
        xp = 25,
        license = 'hunting_license',
        licenseLabel = 'Лицензия на охоту (мэрия)',
        hire = { model = 'a_m_m_hillbilly_01', coords = vector4(-1611.0, 5280.0, 18.0, 180.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        zone = vector3(-1611.0, 5280.0, 18.0),
        zoneRadius = 120.0
    }
}

-- Центральный рынок у площади Легион: скупка ресурсов за наличные
Config.Market = {
    name = 'Центральный рынок',
    coords = vector3(168.0, -878.0, 29.0),
    radius = 60.0,
    stands = {
        { job = 'lumberjack',     model = 'a_m_y_business_01', label = 'Скупка древесины', offset = vector3(0.0, 0.0, 0.0) },
        { job = 'mushroompicker', model = 'a_m_y_business_02', label = 'Скупка грибов',    offset = vector3(2.5, 0.0, 0.0) },
        { job = 'miner',          model = 'a_m_y_business_03', label = 'Скупка руды',      offset = vector3(5.0, 0.0, 0.0) },
        { job = 'oilworker',      model = 'a_m_y_hipster_01',  label = 'Скупка нефти',     offset = vector3(7.5, 0.0, 0.0) },
        { job = 'butcher',        model = 's_m_y_shop_mask',   label = 'Мясная лавка',     offset = vector3(10.0, 0.0, 0.0) },
        { job = 'fisherman',      model = 's_m_y_baywatch_01', label = 'Рыбная лавка',     offset = vector3(12.5, 0.0, 0.0) }
    },
    prices = {
        ['wood'] = 15,
        ['mushroom'] = 12,
        ['ore'] = 25,
        ['oil'] = 30,
        ['raw_meat'] = 20,
        ['fish'] =18
    }
}

-- Заказы такси от игроков: цена за километр, наценка 30% против NPC
Config.Taxi = {
    pricePerKm = 45,
    playerBonus = 0.3,
    destinations = {
        { label = 'Площадь Легион', coords = vector3(195.0, -933.0, 29.0) },
        { label = 'Мэрия',          coords = vector3(-265.0, -963.6, 31.2) },
        { label = 'Больница',       coords = vector3(332.0, -590.0, 43.0) },
        { label = 'Банк',           coords = vector3(149.05, -1041.3, 29.37) },
        { label = 'Автошкола',      coords = vector3(640.0, 1120.0, 285.0) },
        { label = 'Аэропорт ЛС',    coords = vector3(-1035.0, -2730.0, 13.8) },
        { label = 'Пляж Веспуччи',  coords = vector3(-1170.0, -1550.0, 4.0) },
        { label = 'Палето-Бэй',     coords = vector3(80.0, 6424.0, 31.6) },
        { label = 'Сэнди-Шорс',     coords = vector3(1950.0, 3700.0, 32.3) }
    },
    completeRadius = 25.0
}

-- Дальнобой: склады в порту и Палето-Бэй, заказы от бизнесов и маршруты NPC
Config.Trucker = {
    warehouses = {
        { label = 'Склад порта ЛС',   coords = vector3(900.0, -3000.0, 5.9) },
        { label = 'Склад Палето-Бэй', coords = vector3(120.0, 6350.0, 31.6) }
    },
    pricePerUnit = 400,
    rewardPerUnit = 250,
    npcRoutes = {
        { label = 'GO Postal — магазины города', pickup = vector3(69.09, 127.68, 79.21), drop = vector3(25.0, -1346.0, 29.5), reward = 2500 },
        { label = 'Порт — Сэнди-Шорс',           pickup = vector3(900.0, -3000.0, 5.9), drop = vector3(1950.0, 3700.0, 32.3), reward = 4000 },
        { label = 'Палето — Грейпсид',           pickup = vector3(120.0, 6350.0, 31.6), drop = vector3(1700.0, 4800.0, 42.0), reward = 3500 },
        { label = 'Порт — Палето-Бэй',           pickup = vector3(900.0, -3000.0, 5.9), drop = vector3(80.0, 6424.0, 31.6), reward = 5000 },
        { label = 'Склад — аэропорт ЛС',         pickup = vector3(450.0, -2800.0, 5.0), drop = vector3(-1035.0, -2730.0, 13.8), reward = 3000 }
    },
    pickupRadius = 20.0,
    dropRadius = 25.0
}

