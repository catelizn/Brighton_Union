local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_hotel` (
            `citizenid` varchar(50) NOT NULL,
            `loc_key` varchar(32) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

QBCore.Functions.CreateCallback('bu-hotel:server:get', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    local row = MySQL.query.await('SELECT loc_key FROM bu_hotel WHERE citizenid = ? LIMIT 1', { Player.PlayerData.citizenid })
    cb(row and row[1] and row[1].loc_key or nil)
end)

RegisterNetEvent('bu-hotel:server:rent', function(locKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    locKey = tostring(locKey or '')

    local cfg = nil
    for _, h in ipairs(Config.Hotels) do
        if h.key == locKey then cfg = h end
    end
    if not cfg then return end

    local cid = Player.PlayerData.citizenid
    local existing = MySQL.query.await('SELECT citizenid FROM bu_hotel WHERE citizenid = ? LIMIT 1', { cid })
    if existing and existing[1] then
        return TriggerClientEvent('QBCore:Notify', src, 'У тебя уже есть номер в отеле.', 'error')
    end

    if Player.Functions.GetMoney('cash') < Config.Price then
        return TriggerClientEvent('QBCore:Notify', src, 'Недостаточно наличных.', 'error')
    end

    Player.Functions.RemoveMoney('cash', Config.Price, 'hotel-rent')
    MySQL.insert('INSERT INTO bu_hotel (citizenid, loc_key) VALUES (?, ?)', { cid, locKey })
    TriggerClientEvent('QBCore:Notify', src, 'Номер в отеле снят!', 'success')
end)

RegisterNetEvent('bu-hotel:server:unrent', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    MySQL.update('DELETE FROM bu_hotel WHERE citizenid = ?', { Player.PlayerData.citizenid })
    TriggerClientEvent('QBCore:Notify', src, 'Номер сдан.', 'primary')
end)
