local QBCore = exports['qb-core']:GetCoreObject()

local cache = {} -- cid -> { xp, claimed = { [tier]=true } }

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_battlepass` (
            `citizenid` varchar(50) NOT NULL,
            `season` int(11) NOT NULL DEFAULT 1,
            `xp` int(11) NOT NULL DEFAULT 0,
            `claimed` longtext NOT NULL DEFAULT '{}',
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

local function load(cid)
    if cache[cid] then return cache[cid] end
    local row = MySQL.query.await('SELECT xp, claimed FROM bu_battlepass WHERE citizenid = ? AND season = ? LIMIT 1', { cid, Config.Season })
    if row and row[1] then
        cache[cid] = { xp = row[1].xp, claimed = json.decode(row[1].claimed) or {} }
    else
        cache[cid] = { xp = 0, claimed = {} }
    end
    return cache[cid]
end

local function save(cid, entry)
    cache[cid] = entry
    MySQL.insert('INSERT INTO bu_battlepass (citizenid, season, xp, claimed) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE xp = VALUES(xp), claimed = VALUES(claimed)', {
        cid, Config.Season, entry.xp, json.encode(entry.claimed)
    })
end

local function tierOf(entry)
    return math.min(Config.MaxTier, math.floor(entry.xp / Config.XpPerTier))
end

-- Экспорт для других систем: bu-battlepass:addXp(cid, amount)
exports('addXp', function(citizenid, amount)
    local entry = load(citizenid)
    entry.xp = entry.xp + tonumber(amount or 0)
    save(citizenid, entry)
end)

QBCore.Functions.CreateCallback('bu-battlepass:server:getState', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    local entry = load(Player.PlayerData.citizenid)
    cb({
        season = Config.Season,
        xp = entry.xp,
        tier = tierOf(entry),
        maxTier = Config.MaxTier,
        xpPerTier = Config.XpPerTier,
        claimed = entry.claimed,
        tiers = Config.Tiers
    })
end)

RegisterNetEvent('bu-battlepass:server:claim', function(tier)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    tier = tonumber(tier)
    local entry = load(Player.PlayerData.citizenid)
    if not tier or tier < 1 or tier > Config.MaxTier then return end
    if tierOf(entry) < tier then
        return TriggerClientEvent('QBCore:Notify', src, 'Ещё не достигнут этот ярус.', 'error')
    end
    if entry.claimed[tier] then
        return TriggerClientEvent('QBCore:Notify', src, 'Награда уже получена.', 'error')
    end
    entry.claimed[tier] = true
    save(Player.PlayerData.citizenid, entry)

    local r = Config.Tiers[tier]
    if r then
        if r.cash then
            Player.Functions.AddMoney('cash', r.cash, 'battlepass-' .. tier)
        end
        if r.item then
            Player.Functions.AddItem(r.item.name, r.item.amount, false)
        end
    end
    TriggerClientEvent('QBCore:Notify', src, 'Награда получена!', 'success')
end)

-- Админ: добавить XP
RegisterCommand('bpxp', function(source, args)
    if not QBCore.Functions.HasPermission(source, 'admin') then return end
    local amount = tonumber(args[2]) or 100
    local target = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if target then
        exports('addXp', target.PlayerData.citizenid, amount)
        TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Боевой пропуск: +' .. amount .. ' XP.', 'primary')
    end
end)
