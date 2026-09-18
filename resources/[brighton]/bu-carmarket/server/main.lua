local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_vehicle_listings` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `owner` varchar(50) NOT NULL,
            `plate` varchar(16) NOT NULL,
            `model` varchar(64) NOT NULL,
            `price` int(11) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

QBCore.Functions.CreateCallback('bu-carmarket:server:getMy', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end
    local cid = Player.PlayerData.citizenid
    local rows = MySQL.query.await(
        'SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ? AND plate NOT IN (SELECT plate FROM bu_vehicle_listings) LIMIT 30',
        { cid })
    cb(rows or {})
end)

RegisterNetEvent('bu-carmarket:server:list', function(plate, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    plate = tostring(plate or ''):upper():sub(1, 16)
    price = tonumber(price)
    if not price or price < 1 then return end

    local cid = Player.PlayerData.citizenid
    local veh = MySQL.query.await('SELECT plate, vehicle FROM player_vehicles WHERE plate = ? AND citizenid = ? LIMIT 1', { plate, cid })
    if not veh or not veh[1] then
        return TriggerClientEvent('QBCore:Notify', src, 'Это не твоё ТС.', 'error')
    end

    local already = MySQL.query.await('SELECT id FROM bu_vehicle_listings WHERE plate = ? LIMIT 1', { plate })
    if already and already[1] then
        return TriggerClientEvent('QBCore:Notify', src, 'Уже выставлено на продажу.', 'error')
    end

    MySQL.insert('INSERT INTO bu_vehicle_listings (owner, plate, model, price) VALUES (?, ?, ?, ?)', { cid, plate, veh[1].vehicle, price })
    TriggerClientEvent('QBCore:Notify', src, 'Машина выставлена на продажу.', 'success')
end)

RegisterNetEvent('bu-carmarket:server:unlist', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    MySQL.update('DELETE FROM bu_vehicle_listings WHERE plate = ? AND owner = ?', { tostring(plate or ''):upper(), Player.PlayerData.citizenid })
    TriggerClientEvent('QBCore:Notify', src, 'Объявление снято.', 'primary')
end)

QBCore.Functions.CreateCallback('bu-carmarket:server:getListings', function(source, cb)
    local rows = MySQL.query.await('SELECT id, plate, model, price, owner FROM bu_vehicle_listings ORDER BY id DESC LIMIT 40')
    cb(rows or {})
end)

RegisterNetEvent('bu-carmarket:server:buy', function(listingId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    listingId = tonumber(listingId)

    local l = MySQL.query.await('SELECT * FROM bu_vehicle_listings WHERE id = ? LIMIT 1', { listingId })
    if not l or not l[1] then return end
    local item = l[1]

    if item.owner == Player.PlayerData.citizenid then
        return TriggerClientEvent('QBCore:Notify', src, 'Это твоя машина.', 'error')
    end

    if Player.Functions.GetMoney('bank') < item.price then
        return TriggerClientEvent('QBCore:Notify', src, 'Недостаточно средств на счёте.', 'error')
    end

    Player.Functions.RemoveMoney('bank', item.price, 'carmarket-buy')

    local seller = QBCore.Functions.GetPlayerByCitizenId(item.owner)
    local payout = math.floor(item.price * (1 - Config.Commission))
    if seller then
        seller.Functions.AddMoney('bank', payout, 'carmarket-sale')
        TriggerClientEvent('QBCore:Notify', seller.PlayerData.source, string.format('Машина %s продана за $%d.', item.plate, item.price), 'success')
    end

    MySQL.update('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', { Player.PlayerData.citizenid, item.plate })
    MySQL.update('DELETE FROM bu_vehicle_listings WHERE id = ?', { listingId })
    exports['qb-vehiclekeys']:GiveKeys(item.plate, Player.PlayerData.citizenid)
    TriggerClientEvent('QBCore:Notify', src, 'Машина куплена! Ключи выданы.', 'success')
end)
