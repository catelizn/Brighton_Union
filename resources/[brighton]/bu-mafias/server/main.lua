local QBCore = exports['qb-core']:GetCoreObject()

-- Контроль бизнесов: businessKey -> mafiaKey
local control = {}
-- Казна мафий: mafiaKey -> money
local treasury = {}
local lastWar = {}
local lastPaydayHour = nil

local function businessByKey(key)
    for i = 1, #Config.Businesses do
        if Config.Businesses[i].key == key then
            return Config.Businesses[i]
        end
    end
    return nil
end

local function sendBusinessesToMafiaMembers()
    -- Контроль бизнесов видит только участник мафий
    for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
        if Config.Mafias[player.PlayerData.job.name] then
            local list = {}
            for i = 1, #Config.Businesses do
                local business = Config.Businesses[i]
                local owner = control[business.key]
                list[#list + 1] = {
                    key = business.key,
                    label = business.label,
                    coords = business.coords,
                    value = business.value,
                    owner = owner,
                    ownerLabel = owner and Config.Mafias[owner].label or ''
                }
            end
            TriggerClientEvent('bu-mafias:client:businesses', player.PlayerData.source, list)
        else
            TriggerClientEvent('bu-mafias:client:businesses', player.PlayerData.source, {})
        end
    end
end

-- Вступление в мафию у NPC
RegisterNetEvent('bu-mafias:server:join', function(mafiaKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local mafia = Config.Mafias[mafiaKey]
    if not mafia then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - vec3(mafia.coords.x, mafia.coords.y, mafia.coords.z)) > 10.0 then
        TriggerClientEvent('QBCore:Notify', src, 'Подойди к NPC мафии.', 'error')
        return
    end

    if Player.PlayerData.job.name == mafiaKey then
        TriggerClientEvent('QBCore:Notify', src, 'Ты уже в этой мафии.', 'error')
        return
    end

    if Config.Mafias[Player.PlayerData.job.name] then
        TriggerClientEvent('QBCore:Notify', src, 'Сначала покинь текущую мафию (/quitmafia).', 'error')
        return
    end

    Player.Functions.SetJob(mafiaKey, 0)
    TriggerClientEvent('QBCore:Notify', src, 'Ты вступил в мафию: ' .. mafia.label .. '.', 'success')
    sendBusinessesToMafiaMembers()
end)

RegisterCommand(Config.QuitCommand, function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Config.Mafias[Player.PlayerData.job.name] then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не состоишь в мафии.', 'error')
        return
    end

    Player.Functions.SetJob('unemployed', 0)
    TriggerClientEvent('QBCore:Notify', src, 'Ты покинул мафию.', 'inform')
    sendBusinessesToMafiaMembers()
end, false)

RegisterCommand(Config.TreasuryCommand, function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local mafiaKey = Player.PlayerData.job.name
    local mafia = Config.Mafias[mafiaKey]
    if not mafia then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не состоишь в мафии.', 'error')
        return
    end

    local count = 0
    for _, owner in pairs(control) do
        if owner == mafiaKey then count = count + 1 end
    end

    TriggerClientEvent('QBCore:Notify', src, string.format('Казна «%s»: $%d | Бизнесов под контролем: %d', mafia.label, treasury[mafiaKey] or 0, count), 'inform', 8000)
end, false)

-- Снятие из казны: только крёстный отец (ранг 7)
RegisterCommand(Config.WithdrawCommand, function(_, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local mafiaKey = Player.PlayerData.job.name
    local mafia = Config.Mafias[mafiaKey]
    if not mafia then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не состоишь в мафии.', 'error')
        return
    end

    local grade = Player.PlayerData.job.grade.level or 0
    if grade < 7 then
        TriggerClientEvent('QBCore:Notify', src, 'Казна доступна только крёстному отцу.', 'error')
        return
    end

    local amount = tonumber(args and args[1])
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Использование: /mwithdraw [сумма]', 'error')
        return
    end

    local balance = treasury[mafiaKey] or 0
    if amount > balance then
        TriggerClientEvent('QBCore:Notify', src, 'В казне нет столько денег.', 'error')
        return
    end

    treasury[mafiaKey] = balance - amount
    MySQL.update('INSERT INTO bu_mafia_treasury (mafia, money) VALUES (?, ?) ON DUPLICATE KEY UPDATE money = VALUES(money)', { mafiaKey, treasury[mafiaKey] })
    Player.Functions.AddMoney('bank', amount, 'mafia-treasury-withdraw')
    TriggerClientEvent('QBCore:Notify', src, string.format('Снято $%d из казны мафии.', amount), 'success')
end, false)

-- Война за бизнес: удержание точки, чужая мафия срывает
RegisterNetEvent('bu-mafias:server:war', function(businessKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local business = businessByKey(businessKey)
    if not business then return end

    local mafiaKey = Player.PlayerData.job.name
    local mafia = Config.Mafias[mafiaKey]
    if not mafia then
        TriggerClientEvent('QBCore:Notify', src, 'Только участники мафий воюют за бизнесы.', 'error')
        return
    end

    local grade = Player.PlayerData.job.grade.level or 0
    if grade < Config.MinWarRank then
        TriggerClientEvent('QBCore:Notify', src, 'Нужен ранг «Капо» (2) и выше.', 'error')
        return
    end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - business.coords) > 15.0 then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не у бизнеса.', 'error')
        return
    end

    if control[business.key] == mafiaKey then
        TriggerClientEvent('QBCore:Notify', src, 'Бизнес уже под вашим контролем.', 'error')
        return
    end

    local now = os.time()
    if lastWar[mafiaKey] and now - lastWar[mafiaKey] < Config.WarCooldown then
        TriggerClientEvent('QBCore:Notify', src, 'Мафия недавно воевала. Подожди.', 'error')
        return
    end
    lastWar[mafiaKey] = now

    TriggerClientEvent('QBCore:Notify', src, string.format('Война за «%s» началась. Стой у бизнеса %d секунд.', business.label, Config.WarSeconds), 'inform')

    CreateThread(function()
        local cid = Player.PlayerData.citizenid
        local seconds = 0
        while seconds < Config.WarSeconds do
            Wait(5000)
            seconds = seconds + 5

            local target = QBCore.Functions.GetPlayerByCitizenId(cid)
            if not target then
                TriggerClientEvent('QBCore:Notify', src, 'Война сорвана: ты вышел из игры.', 'error')
                return
            end

            local pos = GetEntityCoords(GetPlayerPed(target.PlayerData.source))
            if #(pos - business.coords) > 15.0 then
                TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Война сорвана: ты ушёл от бизнеса.', 'error')
                return
            end

            for _, otherPlayer in pairs(QBCore.Functions.GetQBPlayers()) do
                if otherPlayer.PlayerData.source ~= src then
                    local otherMafia = otherPlayer.PlayerData.job.name
                    if Config.Mafias[otherMafia] and otherMafia ~= mafiaKey then
                        local otherPos = GetEntityCoords(GetPlayerPed(otherPlayer.PlayerData.source))
                        if #(otherPos - business.coords) <= 15.0 then
                            TriggerClientEvent('QBCore:Notify', src, 'Война сорвана: у бизнеса участник чужой мафии.', 'error')
                            return
                        end
                    end
                end
            end
        end

        control[business.key] = mafiaKey
        MySQL.insert('INSERT INTO bu_mafia_control (prop_key, mafia) VALUES (?, ?) ON DUPLICATE KEY UPDATE mafia = VALUES(mafia), captured_at = CURRENT_TIMESTAMP()', {
            business.key, mafiaKey
        })

        TriggerClientEvent('QBCore:Notify', -1, string.format('Мафия «%s» взяла под контроль бизнес «%s»!', mafia.label, business.label), 'success', 8000)
        sendBusinessesToMafiaMembers()
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

        for mafiaKey, mafia in pairs(Config.Mafias) do
            local pay = 0
            local count = 0
            for key, owner in pairs(control) do
                if owner == mafiaKey then
                    local business = businessByKey(key)
                    if business then
                        pay = pay + business.value
                        count = count + 1
                    end
                end
            end

            if pay > 0 then
                treasury[mafiaKey] = (treasury[mafiaKey] or 0) + pay
                MySQL.insert('INSERT INTO bu_mafia_treasury (mafia, money) VALUES (?, ?) ON DUPLICATE KEY UPDATE money = VALUES(money)', { mafiaKey, treasury[mafiaKey] })

                for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
                    if player.PlayerData.job.name == mafiaKey then
                        TriggerClientEvent('QBCore:Notify', player.PlayerData.source, string.format('Payday: мафия «%s» получила $%d за %d бизнесов.', mafia.label, pay, count), 'success', 8000)
                    end
                end
            end
        end

        ::continue::
    end
end)

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_mafia_control` (
            `prop_key` varchar(64) NOT NULL,
            `mafia` varchar(32) NOT NULL DEFAULT '',
            `captured_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`prop_key`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_mafia_treasury` (
            `mafia` varchar(32) NOT NULL,
            `money` bigint(20) NOT NULL DEFAULT 0,
            PRIMARY KEY (`mafia`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        local rows = MySQL.query.await('SELECT prop_key, mafia FROM bu_mafia_control')
        if rows then
            for i = 1, #rows do
                if rows[i].mafia ~= '' and businessByKey(rows[i].prop_key) then
                    control[rows[i].prop_key] = rows[i].mafia
                end
            end
        end

        local moneyRows = MySQL.query.await('SELECT mafia, money FROM bu_mafia_treasury')
        if moneyRows then
            for i = 1, #moneyRows do
                treasury[moneyRows[i].mafia] = moneyRows[i].money
            end
        end

        sendBusinessesToMafiaMembers()
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    SetTimeout(2000, sendBusinessesToMafiaMembers)
end)

-- Админ: /setmafia [id] [mafia] [0-7]
RegisterCommand('setmafia', function(_, args)
    local src = source
    if src ~= 0 and not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('QBCore:Notify', src, 'Нет прав.', 'error')
        return
    end

    local targetId = tonumber(args[1])
    local mafiaKey = args[2]
    local rank = tonumber(args[3])
    local target = targetId and QBCore.Functions.GetPlayer(targetId)
    if not target or not Config.Mafias[mafiaKey] or not rank or rank < 0 or rank > 7 then
        TriggerClientEvent('QBCore:Notify', src, 'Использование: /setmafia [id] [mafia] [0-7]', 'error')
        return
    end

    target.Functions.SetJob(mafiaKey, rank)
    sendBusinessesToMafiaMembers()
end, false)
