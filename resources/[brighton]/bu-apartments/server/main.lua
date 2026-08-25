local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_apartments` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `building` varchar(32) NOT NULL,
            `number` int(11) NOT NULL,
            `owner` varchar(50) NOT NULL DEFAULT '',
            `price` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`),
            UNIQUE KEY `uq_flat` (`building`, `number`),
            KEY `idx_owner` (`owner`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        MySQL.query("ALTER TABLE `bu_apartments` ADD COLUMN IF NOT EXISTS `interior` varchar(16) NOT NULL DEFAULT 'standard'")
    end)
end)

QBCore.Functions.CreateCallback('bu-apartments:server:getBuilding', function(source, cb, buildingKey)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local building = Config.Buildings[1]
    for i = 1, #Config.Buildings do
        if Config.Buildings[i].key == buildingKey then
            building = Config.Buildings[i]
        end
    end

    local result = MySQL.query.await('SELECT number, owner, price, interior FROM bu_apartments WHERE building = ? ORDER BY number ASC', { building.key })

    local flats = {}
    local ownedByPlayer = 0
    for i = 1, building.apartments do
        flats[i] = { number = i, owner = '', price = building.price, interior = 'standard' }
    end
    if result then
        for i = 1, #result do
            local row = result[i]
            if row.owner == Player.PlayerData.citizenid then
                flats[row.number] = { number = row.number, owner = 'me', price = row.price, interior = row.interior or 'standard' }
                ownedByPlayer = ownedByPlayer + 1
            else
                flats[row.number] = { number = row.number, owner = 'other', price = row.price, interior = row.interior or 'standard' }
            end
        end
    end

    cb({
        key = building.key,
        label = building.label,
        price = building.price,
        flats = flats,
        myFlats = ownedByPlayer,
        maxFlats = Config.MaxApartmentsPerBuilding,
        interiors = Config.Interiors
    })
end)

RegisterNetEvent('bu-apartments:server:buy', function(buildingKey, number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local building = Config.Buildings[1]
    for i = 1, #Config.Buildings do
        if Config.Buildings[i].key == buildingKey then
            building = Config.Buildings[i]
        end
    end

    number = tonumber(number)
    if not number or number < 1 or number > building.apartments then return end

    local existing = MySQL.query.await('SELECT owner FROM bu_apartments WHERE building = ? AND number = ? LIMIT 1', { building.key, number })
    if existing and existing[1] and existing[1].owner ~= '' then
        TriggerClientEvent('bu-apartments:client:notify', src, 'Эта квартира уже куплена.', 'error')
        return
    end

    local mine = MySQL.query.await('SELECT COUNT(*) AS count FROM bu_apartments WHERE building = ? AND owner = ?', { building.key, Player.PlayerData.citizenid })
    local myCount = mine and mine[1] and mine[1].count or 0
    if myCount >= Config.MaxApartmentsPerBuilding then
        TriggerClientEvent('bu-apartments:client:notify', src, 'В этом доме у тебя уже есть квартира.', 'error')
        return
    end

    local bank = Player.PlayerData.money.bank
    if not bank or bank < building.price then
        TriggerClientEvent('bu-apartments:client:notify', src, string.format('Нужно $%d на банковском счёте.', building.price), 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', building.price, 'apartment-buy-' .. building.key .. '-' .. number)

    if existing and existing[1] then
        MySQL.update('UPDATE bu_apartments SET owner = ?, price = ? WHERE building = ? AND number = ?', { Player.PlayerData.citizenid, building.price, building.key, number })
    else
        MySQL.insert('INSERT INTO bu_apartments (building, number, owner, price) VALUES (?, ?, ?, ?)', { building.key, number, Player.PlayerData.citizenid, building.price })
    end

    TriggerClientEvent('bu-apartments:client:notify', src, string.format('Квартира №%d куплена. Входи через «Жилой дом».', number), 'success')
end)

-- Покупка набора мебели: только владелец, оплата с банка
RegisterNetEvent('bu-apartments:server:buyInterior', function(buildingKey, number, interiorId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local interior = nil
    for i = 1, #Config.Interiors do
        if Config.Interiors[i].id == interiorId then
            interior = Config.Interiors[i]
        end
    end
    if not interior then return end

    number = tonumber(number)
    if not number then return end

    local flat = MySQL.query.await('SELECT owner FROM bu_apartments WHERE building = ? AND number = ? LIMIT 1', { buildingKey, number })
    if not flat or not flat[1] or flat[1].owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-apartments:client:notify', src, 'Квартира не твоя.', 'error')
        return
    end

    local bank = Player.PlayerData.money.bank
    if not bank or bank < interior.price then
        TriggerClientEvent('bu-apartments:client:notify', src, string.format('Нужно $%d на банковском счёте.', interior.price), 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', interior.price, 'apartment-interior-' .. interior.id)
    MySQL.update('UPDATE bu_apartments SET interior = ? WHERE building = ? AND number = ?', { interior.id, buildingKey, number })

    TriggerClientEvent('bu-apartments:client:notify', src, interior.label .. ' установлена.', 'success')
    TriggerClientEvent('bu-apartments:client:interiorChanged', src, interior.id)
end)
