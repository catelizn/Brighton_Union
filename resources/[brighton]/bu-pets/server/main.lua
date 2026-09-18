local QBCore = exports['qb-core']:GetCoreObject()

local pets = {} -- cid -> { model, name }

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_pets` (
            `citizenid` varchar(50) NOT NULL,
            `model` varchar(64) NOT NULL,
            `name` varchar(32) NOT NULL DEFAULT 'Питомец',
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

QBCore.Functions.CreateCallback('bu-pets:server:get', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    local cid = Player.PlayerData.citizenid
    if pets[cid] then return cb(pets[cid]) end
    local result = MySQL.query.await('SELECT model, name FROM bu_pets WHERE citizenid = ? LIMIT 1', { cid })
    if result and result[1] then
        pets[cid] = { model = result[1].model, name = result[1].name }
        return cb(pets[cid])
    end
    cb(nil)
end)

RegisterNetEvent('bu-pets:server:adopt', function(modelKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cfg = Config.Pets[tonumber(modelKey)]
    if not cfg then return end

    local cid = Player.PlayerData.citizenid
    if pets[cid] then
        TriggerClientEvent('QBCore:Notify', src, 'У тебя уже есть питомец.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < cfg.price then
        TriggerClientEvent('QBCore:Notify', src, 'Недостаточно наличных.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', cfg.price, 'pet-adopt')
    MySQL.insert('INSERT INTO bu_pets (citizenid, model, name) VALUES (?, ?, ?)', { cid, cfg.model, 'Питомец' })
    pets[cid] = { model = cfg.model, name = 'Питомец' }
    TriggerClientEvent('bu-pets:client:adopted', src, pets[cid])
    TriggerClientEvent('QBCore:Notify', src, 'Питомец принят!', 'success')
end)

RegisterNetEvent('bu-pets:server:rename', function(name)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    name = tostring(name or ''):sub(1, 32)
    if pets[cid] and name ~= '' then
        pets[cid].name = name
        MySQL.update('UPDATE bu_pets SET name = ? WHERE citizenid = ?', { name, cid })
        TriggerClientEvent('bu-pets:client:renamed', src, name)
    end
end)
