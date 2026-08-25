Config = Config or {}

-- Банды — пресетные криминальные фракции (как на Majestic RP / GTA5RP).
-- 10 рангов: 0 рекрут ... 9 босс. Вступить можно только у NPC на районе.
Config.Gangs = {
    families = {
        label = 'The Families',
        joinLabel = 'Вступить в The Families',
        coords = vector4(140.0, -1660.0, 29.0, 180.0),
        model = 'g_m_y_famca_01',
        color = 2
    },
    ballas = {
        label = 'Ballas',
        joinLabel = 'Вступить в Ballas',
        coords = vector4(70.0, -1900.0, 21.0, 180.0),
        model = 'g_m_y_ballaeast_01',
        color = 7
    },
    vagos = {
        label = 'Vagos',
        joinLabel = 'Вступить в Vagos',
        coords = vector4(350.0, -1980.0, 22.0, 180.0),
        model = 'g_m_y_mexgoon_01',
        color = 5
    },
    bloods = {
        label = 'Bloods',
        joinLabel = 'Вступить в Bloods',
        coords = vector4(-220.0, -1520.0, 32.0, 180.0),
        model = 'g_m_y_strpunk_01',
        color = 1
    },
    marabunta = {
        label = 'Marabunta',
        joinLabel = 'Вступить в Marabunta',
        coords = vector4(330.0, -1450.0, 28.0, 180.0),
        model = 'g_m_y_salvagoon_01',
        color = 3
    }
}

-- Домашний район каждой банды: стартовые квадраты распределяются по нему
Config.GangHome = {
    families = 'grove',
    ballas = 'davis',
    vagos = 'rancho',
    bloods = 'chamberlain',
    marabunta = 'strawberry'
}

-- Гетто: 5 районов по 12 квадратов = 60 зон. Сетка строится от угла района.
local function gridZones(prefix, label, start, cols, rows)
    local zones = {}
    local index = 0
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            index = index + 1
            zones[#zones + 1] = {
                key = prefix .. '_' .. index,
                label = label .. ' ' .. index,
                coords = vector3(start.x + col * 24.0, start.y + row * 24.0, start.z),
                radius = 32.0
            }
        end
    end
    return zones
end

Config.Ghetto = {
    grove = gridZones('grove', 'Гроув-стрит', vector3(70.0, -1990.0, 21.0), 4, 3),
    davis = gridZones('davis', 'Дэвис', vector3(55.0, -1775.0, 23.0), 4, 3),
    rancho = gridZones('rancho', 'Ранчо', vector3(290.0, -2010.0, 22.0), 4, 3),
    chamberlain = gridZones('chamberlain', 'Чемберлен-Хиллз', vector3(-390.0, -1720.0, 30.0), 4, 3),
    strawberry = gridZones('strawberry', 'Строберри', vector3(250.0, -1550.0, 28.0), 4, 3)
}

-- Квадрат считается соседним, если его центр ближе этой дистанции к твоему
Config.AdjacentDistance = 45.0

-- Капт: сколько секунд удерживать и с какого ранга
Config.CaptureSeconds = 60
Config.MinCaptureRank = 3          -- «Авторитет» и выше
Config.CaptureCooldown = 300       -- секунд между попытками одной банды

-- Payday: каждый час в :00 минут каждая зона приносит банде деньги в казну
Config.ZonePayout = 250
Config.ZoneLeaderBonus = 400       -- бонус за контроль 100% гетто (в час, на участника)

-- Команды
Config.QuitCommand = 'quitgang'
Config.TreasuryCommand = 'gangmoney'
Config.WithdrawCommand = 'gwithdraw'

