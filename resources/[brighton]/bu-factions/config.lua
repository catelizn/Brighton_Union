Config = Config or {}

-- Базы фракций: у каждой банды, мафии и госструктуры свой вход, интерьер,
-- спавн (выбирается при входе в игру) и склад. Госструктуры — ещё и гардероб.
-- door — точка входа на карте, внутри строится копия интерьера под землёй.

Config.InteriorZ = -250.0

Config.Bases = {
    -- ===== БАНДЫ (цвета как в GTA: San Andreas) =====
    families = {
        type = 'gang',
        label = 'The Families',
        door = vector4(140.0, -1660.0, 29.0, 180.0),
        color = 2,          -- зелёные
        blipSprite = 84,    -- череп
        questModel = 'g_m_y_famca_01',
        interior = { model = 'shell_v16mid', exit = vector4(1.561, -14.305, 1.147, 2.263) }
    },
    ballas = {
        type = 'gang',
        label = 'Ballas',
        door = vector4(70.0, -1900.0, 21.0, 180.0),
        color = 27,         -- фиолетовые
        blipSprite = 84,
        questModel = 'g_m_y_ballaeast_01',
        interior = { model = 'shell_v16mid', exit = vector4(1.561, -14.305, 1.147, 2.263) }
    },
    marabunta = {
        type = 'gang',
        label = 'Marabunta',
        door = vector4(330.0, -1450.0, 28.0, 180.0),
        color = 3,          -- голубые
        blipSprite = 84,
        questModel = 'g_m_y_salvagoon_01',
        interior = { model = 'shell_v16mid', exit = vector4(1.561, -14.305, 1.147, 2.263) }
    },
    vagos = {
        type = 'gang',
        label = 'Vagos',
        door = vector4(350.0, -1980.0, 22.0, 180.0),
        color = 5,          -- жёлтые
        blipSprite = 84,
        questModel = 'g_m_y_mexgoon_01',
        interior = { model = 'shell_v16mid', exit = vector4(1.561, -14.305, 1.147, 2.263) }
    },
    bloods = {
        type = 'gang',
        label = 'Bloods',
        door = vector4(-220.0, -1520.0, 32.0, 180.0),
        color = 1,          -- красные
        blipSprite = 84,
        questModel = 'g_m_y_strpunk_01',
        interior = { model = 'shell_v16mid', exit = vector4(1.561, -14.305, 1.147, 2.263) }
    },

    -- ===== МАФИИ =====
    italian_mafia = {
        type = 'mafia',
        label = 'Итальянская мафия',
        door = vector4(935.0, 50.0, 81.0, 180.0),
        color = 52,         -- салатовые
        blipSprite = 310,   -- знак группировки (не череп)
        questModel = 'g_m_y_italydoom_01',
        interior = { model = 'shell_michael', exit = vector4(-9.49, 5.54, 9.91, 270.86) }
    },
    russian_mafia = {
        type = 'mafia',
        label = 'Русская мафия',
        door = vector4(-1330.0, -1100.0, 7.0, 180.0),
        color = 40,         -- чёрные
        blipSprite = 310,
        questModel = 'g_m_y_slavboss_01',
        interior = { model = 'shell_michael', exit = vector4(-9.49, 5.54, 9.91, 270.86) }
    },
    mexican_mafia = {
        type = 'mafia',
        label = 'Мексиканская мафия',
        door = vector4(600.0, -2300.0, 22.0, 180.0),
        color = 6,          -- оранжевые
        blipSprite = 310,
        questModel = 'g_m_y_mexboss_01',
        interior = { model = 'shell_michael', exit = vector4(-9.49, 5.54, 9.91, 270.86) }
    },
    yakuza = {
        type = 'mafia',
        label = 'Японская мафия',
        door = vector4(500.0, -3100.0, 5.0, 180.0),
        color = 0,          -- белые
        blipSprite = 310,
        questModel = 'g_m_y_yakuza_01',
        interior = { model = 'shell_michael', exit = vector4(-9.49, 5.54, 9.91, 270.86) }
    },

    -- ===== ГОССТРУКТУРЫ =====
    police = {
        type = 'gov',
        label = 'LSPD',
        door = vector4(441.3, -981.7, 30.7, 90.0),
        color = 38,
        blipSprite = 60,
        wardrobe = true,
        questModel = 's_m_y_cop_01',
        interior = { model = 'shell_office1', exit = vector4(1.88, 5.06, 2.05, 180.07) }
    },
    ambulance = {
        type = 'gov',
        label = 'Больница',
        door = vector4(307.0, -1431.0, 30.0, 90.0),
        color = 1,
        blipSprite = 61,
        wardrobe = true,
        questModel = 's_m_m_doctor_01',
        interior = { model = 'shell_office1', exit = vector4(1.88, 5.06, 2.05, 180.07) }
    },
    fib = {
        type = 'gov',
        label = 'FIB',
        door = vector4(155.7, -739.7, 33.0, 90.0),
        color = 26,
        blipSprite = 526,
        wardrobe = true,
        questModel = 's_m_m_fiboffice_01',
        interior = { model = 'shell_office1', exit = vector4(1.88, 5.06, 2.05, 180.07) }
    },
    weazel = {
        type = 'gov',
        label = 'Weazel News',
        door = vector4(545.0, -930.0, 27.5, 90.0),
        color = 1,
        blipSprite = 590,
        wardrobe = true,
        questModel = 's_m_m_highsec_01',
        interior = { model = 'shell_office1', exit = vector4(1.88, 5.06, 2.05, 180.07) }
    }
}

-- Смещения точек внутри базы от выхода интерьера
Config.InteriorStash = { x = 2.0, y = -1.5, z = 0.0 }
Config.InteriorWardrobe = { x = -2.0, y = -1.5, z = 0.0 }

-- Общий склад фракции (блип у входа, точка внутри)
Config.Stash = {
    maxweight = 1000000,
    slots = 50,
    blipSprite = 408,
    blipColor = 2,
    labelSuffix = 'Склад'
}

-- Блип гардероба (только госструктуры)
Config.Wardrobe = {
    blipSprite = 366,
    blipColor = 0,
    labelSuffix = 'Гардероб'
}

-- ===== Квесты банд: выдаёт NPC на базе, кулдаун после выполнения =====
Config.GangQuests = {
    robbery = {
        label = 'Задание: ограбление дома',
        reward = 2500,
        cooldown = 300,      -- 5 минут после выполнения
        lockpicks = 2
    },
    cartheft = {
        label = 'Задание: угон машины',
        reward = 1800,
        cooldown = 300,
        lockpicks = 2,
        chop = vector3(950.0, -2300.0, 30.0)   -- точка сдачи краденого
    }
}

-- ===== Квесты мафий =====
Config.MafiaQuests = {
    contraband = {
        label = 'Задание: контрабанда',
        reward = 3500,
        cooldown = 180      -- 3 минуты после выполнения
    },
    hooker = {
        label = 'Задание: развоз проституток',
        reward = 2000,
        cooldown = 180,
        timeout = 600       -- минут нет, это секунды на выполнение
    }
}

-- Тёмные NPC: принимают контрабанду в укромных местах
Config.DarkSpots = {
    { coords = vector4(950.0, -3000.0, 6.0, 90.0),    model = 'g_m_m_armboss_01' },
    { coords = vector4(2400.0, 3150.0, 48.0, 180.0),  model = 'g_m_m_armgoon_01' },
    { coords = vector4(700.0, 6500.0, 25.0, 180.0),   model = 'g_m_m_armlieut_01' },
    { coords = vector4(-700.0, 5800.0, 30.0, 180.0),  model = 'g_m_y_mexgoon_03' }
}

-- Развоз проституток: забираешь у мотеля, везёшь клиенту
Config.Hooker = {
    model = 's_f_y_hooker_01',
    pickup = vector4(320.0, -200.0, 54.0, 180.0),
    drops = {
        vector3(-1500.0, -900.0, 9.0),
        vector3(900.0, -1500.0, 25.0),
        vector3(-1800.0, -300.0, 50.0),
        vector3(200.0, 3000.0, 42.0)
    }
}

-- NPC на базах
Config.ClerkLabel = 'Клерк'
Config.NpcScenario = 'WORLD_HUMAN_STAND_MOBILE'
