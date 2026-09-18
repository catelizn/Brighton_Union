local QBCore = exports['qb-core']:GetCoreObject()

local function isPolice(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    for _, job in ipairs(Config.PoliceJobs) do
        if Player.PlayerData.job.name == job then return true end
    end
    return false
end

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_wanted` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `reason` varchar(255) NOT NULL,
            `level` varchar(16) NOT NULL DEFAULT 'low',
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

local function getWarrants(citizenid)
    local rows = MySQL.query.await('SELECT id, reason, level, created_at FROM bu_wanted WHERE citizenid = ? ORDER BY id DESC LIMIT 20', { citizenid })
    return rows or {}
end

-- Поиск игрока по citizenid или части имени
QBCore.Functions.CreateCallback('bu-policemd:server:searchPlayer', function(source, cb, query)
    if not isPolice(source) then return cb({ error = 'Доступ только у полиции.' }) end
    query = tostring(query or ''):sub(1, 64)
    if query == '' then return cb({ players = {} }) end

    local players = MySQL.query.await(
        'SELECT citizenid, firstname, lastname FROM players WHERE citizenid = ? OR CONCAT(firstname, " ", lastname) LIKE ? LIMIT 10',
        { query, '%' .. query .. '%' }
    )
    cb({ players = players or {} })
end)

-- Профиль игрока + его авто + ордера
QBCore.Functions.CreateCallback('bu-policemd:server:getProfile', function(source, cb, citizenid)
    if not isPolice(source) then return cb({ error = 'Доступ только у полиции.' }) end
    citizenid = tostring(citizenid or '')

    local row = MySQL.query.await('SELECT citizenid, firstname, lastname FROM players WHERE citizenid = ? LIMIT 1', { citizenid })
    if not row or not row[1] then return cb({ error = 'Игрок не найден.' }) end

    local vehicles = MySQL.query.await('SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ? LIMIT 20', { citizenid })
    local warrants = getWarrants(citizenid)

    cb({
        citizenid = row[1].citizenid,
        name = row[1].firstname .. ' ' .. row[1].lastname,
        vehicles = vehicles or {},
        warrants = warrants
    })
end)

-- Поиск ТС по номеру
QBCore.Functions.CreateCallback('bu-policemd:server:searchVehicle', function(source, cb, plate)
    if not isPolice(source) then return cb({ error = 'Доступ только у полиции.' }) end
    plate = tostring(plate or ''):upper():sub(1, 16)
    if plate == '' then return cb({ vehicle = nil }) end

    local row = MySQL.query.await('SELECT plate, vehicle, citizenid FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
    cb({ vehicle = row and row[1] or nil })
end)

-- Добавить / снять ордер
RegisterNetEvent('bu-policemd:server:addWarrant', function(citizenid, reason, level)
    local src = source
    if not isPolice(src) then return end
    reason = tostring(reason or ''):sub(1, 255)
    if reason == '' then return end
    citizenid = tostring(citizenid or '')

    MySQL.insert('INSERT INTO bu_wanted (citizenid, reason, level) VALUES (?, ?, ?)', { citizenid, reason, level or 'low' })
    TriggerClientEvent('bu-policemd:client:refresh', src, citizenid)
end)

RegisterNetEvent('bu-policemd:server:removeWarrant', function(warrantId)
    local src = source
    if not isPolice(src) then return end
    MySQL.update('DELETE FROM bu_wanted WHERE id = ?', { tonumber(warrantId) })
    TriggerClientEvent('bu-policemd:client:refresh', src, nil)
end)

QBCore.Functions.CreateCallback('bu-policemd:server:isPolice', function(source, cb)
    cb(isPolice(source))
end)
