local QBCore = exports['qb-core']:GetCoreObject()

-- Все квадраты гетто: key -> { key, label, coords, radius, home }
local zones = {}
-- Владельцы: zoneKey -> gangKey
local zoneOwners = {}
-- Казна банд: gangKey -> money
local treasury = {}
-- Кулдауны каптов: gangKey -> os.time()
local lastCapture = {}
local lastPaydayHour = nil

local function zoneList()
    local list = {}
    for key, zone in pairs(zones) do
        list[#list + 1] = zone
    end
    return list
end

local function sendZonesToGangMembers()
    -- Зоны видит ТОЛЬКО участник банд
    for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
        if Config.Gangs[player.PlayerData.job.name] then
            local list = {}
            for _, zone in ipairs(zoneList()) do
                local owner = zoneOwners[zone.key]
                list[#list + 1] = {
                    key = zone.key,
                    label = zone.label,
                    coords = zone.coords,
                    radius = zone.radius,
                    owner = owner,
                    ownerLabel = owner and Config.Gangs[owner].label or ''
                }
            end
            TriggerClientEvent('bu-gangs:client:zones', player.PlayerData.source, list)
        else
            TriggerClientEvent('bu-gangs:client:zones', player.PlayerData.source, {})
        end
    end
end

local function ownedZones(gangKey)
    local count = 0
    for _, owner in pairs(zoneOwners) do
        if owner == gangKey then count = count + 1 end
    end
    return count
end

local function countZones()
    local count = 0
    for _ in pairs(zones) do count = count + 1 end
    return count
end

local function isAdjacent(zoneKey, gangKey)
    local target = zones[zoneKey]
    for key, owner in pairs(zoneOwners) do
        if owner == gangKey and #(zones[key].coords - target.coords) <= Config.AdjacentDistance then
            return true
        end
    end
    return false
end

-- Вступление в банду у NPC на районе
RegisterNetEvent('bu-gangs:server:join', function(gangKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local gang = Config.Gangs[gangKey]
    if not gang then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - vec3(gang.coords.x, gang.coords.y, gang.coords.z)) > 10.0 then
        TriggerClientEvent('QBCore:Notify', src, 'Подойди к NPC банды на районе.', 'error')
        return
    end

    if Player.PlayerData.job.name == gangKey then
        TriggerClientEvent('QBCore:Notify', src, 'Ты уже в этой банде.', 'error')
        return
    end

    if Config.Gangs[Player.PlayerData.job.name] then
        TriggerClientEvent('QBCore:Notify', src, 'Сначала покинь текущую банду (/quitgang).', 'error')
        return
    end

    Player.Functions.SetJob(gangKey, 0)
    TriggerClientEvent('QBCore:Notify', src, 'Ты вступил в банду «' .. gang.label .. '».', 'success')
    sendZonesToGangMembers()
end)

RegisterCommand(Config.QuitCommand, function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Config.Gangs[Player.PlayerData.job.name] then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не состоишь в банде.', 'error')
        return
    end

    Player.Functions.SetJob('unemployed', 0)
    TriggerClientEvent('QBCore:Notify', src, 'Ты покинул банду.', 'inform')
    sendZonesToGangMembers()
end, false)

-- Казна банды
RegisterCommand(Config.TreasuryCommand, function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local gangKey = Player.PlayerData.job.name
    local gang = Config.Gangs[gangKey]
    if not gang then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не состоишь в банде.', 'error')
        return
    end

    TriggerClientEvent('QBCore:Notify', src, string.format('Казна «%s»: $%d | Квадратов: %d', gang.label, treasury[gangKey] or 0, ownedZones(gangKey)), 'inform', 8000)
end, false)

-- Снятие из казны: только босс (ранг 9)
RegisterCommand(Config.WithdrawCommand, function(_, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local gangKey = Player.PlayerData.job.name
    local gang = Config.Gangs[gangKey]
    if not gang then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не состоишь в банде.', 'error')
        return
    end

    local grade = Player.PlayerData.job.grade.level or 0
    if grade < 9 then
        TriggerClientEvent('QBCore:Notify', src, 'Казна доступна только боссу.', 'error')
        return
    end

    local amount = tonumber(args and args[1])
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Использование: /gwithdraw [сумма]', 'error')
        return
    end

    local balance = treasury[gangKey] or 0
    if amount > balance then
        TriggerClientEvent('QBCore:Notify', src, 'В казне нет столько денег.', 'error')
        return
    end

    treasury[gangKey] = balance - amount
    MySQL.update('INSERT INTO bu_gang_treasury (gang, money) VALUES (?, ?) ON DUPLICATE KEY UPDATE money = VALUES(money)', { gangKey, treasury[gangKey] })
    Player.Functions.AddMoney('bank', amount, 'gang-treasury-withdraw')
    TriggerClientEvent('QBCore:Notify', src, string.format('Снято $%d из казны банды.', amount), 'success')
end, false)

-- Капт квадрата: только соседний с твоими, удержание, чужая банда срывает
RegisterNetEvent('bu-gangs:server:capture', function(zoneKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local zone = zones[zoneKey]
    if not zone then return end

    local gangKey = Player.PlayerData.job.name
    local gang = Config.Gangs[gangKey]
    if not gang then
        TriggerClientEvent('QBCore:Notify', src, 'Только участники банд захватывают территории.', 'error')
        return
    end

    local grade = Player.PlayerData.job.grade.level or 0
    if grade < Config.MinCaptureRank then
        TriggerClientEvent('QBCore:Notify', src, 'Нужен ранг «Авторитет» (3) и выше.', 'error')
        return
    end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - zone.coords) > zone.radius then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не в квадрате.', 'error')
        return
    end

    if zoneOwners[zone.key] == gangKey then
        TriggerClientEvent('QBCore:Notify', src, 'Квадрат уже ваш.', 'error')
        return
    end

    if not isAdjacent(zone.key, gangKey) then
        TriggerClientEvent('QBCore:Notify', src, 'Захватывать можно только квадрат, соседний с вашими.', 'error')
        return
    end

    local now = os.time()
    if lastCapture[gangKey] and now - lastCapture[gangKey] < Config.CaptureCooldown then
        TriggerClientEvent('QBCore:Notify', src, 'Банда недавно пыталась захватить квадрат. Подожди.', 'error')
        return
    end
    lastCapture[gangKey] = now

    TriggerClientEvent('QBCore:Notify', src, string.format('Захват «%s» начался. Стой в квадрате %d секунд.', zone.label, Config.CaptureSeconds), 'inform')

    CreateThread(function()
        local cid = Player.PlayerData.citizenid
        local seconds = 0
        while seconds < Config.CaptureSeconds do
            Wait(5000)
            seconds = seconds + 5

            local target = QBCore.Functions.GetPlayerByCitizenId(cid)
            if not target then
                TriggerClientEvent('QBCore:Notify', src, 'Захват сорван: ты вышел из игры.', 'error')
                return
            end

            local pos = GetEntityCoords(GetPlayerPed(target.PlayerData.source))
            if #(pos - zone.coords) > zone.radius then
                TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Захват сорван: ты покинул квадрат.', 'error')
                return
            end

            for _, otherPlayer in pairs(QBCore.Functions.GetQBPlayers()) do
                if otherPlayer.PlayerData.source ~= src then
                    local otherGang = otherPlayer.PlayerData.job.name
                    if Config.Gangs[otherGang] and otherGang ~= gangKey then
                        local otherPos = GetEntityCoords(GetPlayerPed(otherPlayer.PlayerData.source))
                        if #(otherPos - zone.coords) <= zone.radius then
                            TriggerClientEvent('QBCore:Notify', src, 'Захват сорван: в квадрате участник чужой банды.', 'error')
                            return
                        end
                    end
                end
            end
        end

        zoneOwners[zone.key] = gangKey
        MySQL.insert('INSERT INTO bu_gang_zones (zone_key, gang) VALUES (?, ?) ON DUPLICATE KEY UPDATE gang = VALUES(gang), captured_at = CURRENT_TIMESTAMP()', {
            zone.key, gangKey
        })

        TriggerClientEvent('QBCore:Notify', -1, string.format('Банда «%s» захватила квадрат «%s»!', gang.label, zone.label), 'success', 8000)

        if ownedZones(gangKey) >= countZones() then
            TriggerClientEvent('QBCore:Notify', -1, string.format('Банда «%s» контролирует 100%% гетто и стала лидером района!', gang.label), 'success', 12000)
        end

        sendZonesToGangMembers()
    end)
end)

-- Payday: каждый час в :00 минут
CreateThread(function()
    while true do
        Wait(20000)

        local hour = os.date('%H')
        if hour == lastPaydayHour then
            goto continue
        end
        lastPaydayHour = hour

        for gangKey, gang in pairs(Config.Gangs) do
            local count = ownedZones(gangKey)
            if count > 0 then
                local pay = count * Config.ZonePayout
                treasury[gangKey] = (treasury[gangKey] or 0) + pay
                MySQL.insert('INSERT INTO bu_gang_treasury (gang, money) VALUES (?, ?) ON DUPLICATE KEY UPDATE money = VALUES(money)', { gangKey, treasury[gangKey] })

                for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
                    if player.PlayerData.job.name == gangKey then
                        TriggerClientEvent('QBCore:Notify', player.PlayerData.source, string.format('Payday: банда «%s» получила $%d за %d квадратов.', gang.label, pay, count), 'success', 8000)
                    end
                end
            end

            -- Бонус лидера гетто: контроль 100%
            if count >= countZones() and count > 0 then
                for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
                    if player.PlayerData.job.name == gangKey then
                        player.Functions.AddMoney('cash', Config.ZoneLeaderBonus, 'gang-leader-bonus')
                        TriggerClientEvent('QBCore:Notify', player.PlayerData.source, 'Бонус лидера гетто: +$' .. Config.ZoneLeaderBonus, 'success')
                    end
                end
            end
        end

        ::continue::
    end
end)

-- Таблица квадратов, казна, стартовое распределение районов
CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_gang_zones` (
            `zone_key` varchar(32) NOT NULL,
            `gang` varchar(32) NOT NULL DEFAULT '',
            `captured_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`zone_key`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_gang_treasury` (
            `gang` varchar(32) NOT NULL,
            `money` bigint(20) NOT NULL DEFAULT 0,
            PRIMARY KEY (`gang`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        -- Собираем квадраты из конфига
        for home, homeZones in pairs(Config.Ghetto) do
            for i = 1, #homeZones do
                local zone = homeZones[i]
                zone.home = home
                zones[zone.key] = zone
            end
        end

        local rows = MySQL.query.await('SELECT zone_key, gang FROM bu_gang_zones')
        if rows and #rows > 0 then
            for i = 1, #rows do
                if rows[i].gang ~= '' and zones[rows[i].zone_key] then
                    zoneOwners[rows[i].zone_key] = rows[i].gang
                end
            end
        end

        -- Дозаполняем квадраты без владельца домашним районом банды
        -- (важно после обновления конфига с прошлых версий)
        for gangKey, home in pairs(Config.GangHome) do
            for key, zone in pairs(zones) do
                if zone.home == home and not zoneOwners[key] then
                    zoneOwners[key] = gangKey
                    MySQL.insert('INSERT INTO bu_gang_zones (zone_key, gang) VALUES (?, ?) ON DUPLICATE KEY UPDATE gang = VALUES(gang)', { key, gangKey })
                end
            end
        end

        -- Чистим ключи, которых больше нет в конфиге
        local allRows = MySQL.query.await('SELECT zone_key FROM bu_gang_zones')
        if allRows then
            for i = 1, #allRows do
                if not zones[allRows[i].zone_key] then
                    MySQL.query('DELETE FROM bu_gang_zones WHERE zone_key = ?', { allRows[i].zone_key })
                end
            end
        end

        local moneyRows = MySQL.query.await('SELECT gang, money FROM bu_gang_treasury')
        if moneyRows then
            for i = 1, #moneyRows do
                treasury[moneyRows[i].gang] = moneyRows[i].money
            end
        end

        sendZonesToGangMembers()
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    SetTimeout(2000, sendZonesToGangMembers)
end)

-- Админ: выдать ранг в банде для теста /setgang [id] [gang] [rank]
RegisterCommand('setgang', function(_, args, raw)
    local src = source
    if src ~= 0 and not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('QBCore:Notify', src, 'Нет прав.', 'error')
        return
    end

    local targetId = tonumber(args[1])
    local gangKey = args[2]
    local rank = tonumber(args[3])
    local target = targetId and QBCore.Functions.GetPlayer(targetId)
    if not target or not Config.Gangs[gangKey] or not rank or rank < 0 or rank > 9 then
        TriggerClientEvent('QBCore:Notify', src, 'Использование: /setgang [id] [gang] [0-9]', 'error')
        return
    end

    target.Functions.SetJob(gangKey, rank)
    sendZonesToGangMembers()
end, false)

