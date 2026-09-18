local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_listings` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `owner` varchar(50) NOT NULL,
            `key` varchar(64) NOT NULL,
            `label` varchar(64) NOT NULL,
            `price` int(11) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

-- Мои бизнесы (не выставленные на продажу)
QBCore.Functions.CreateCallback('bu-realtor:server:getMine', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end
    local cid = Player.PlayerData.citizenid

    local owned = MySQL.query.await('SELECT prop_key, label, price FROM bu_properties WHERE owner = ?', { cid })
    local listed = {}
    local listing = MySQL.query.await('SELECT `key` FROM bu_listings WHERE owner = ?', { cid })
    for _, l in ipairs(listing or {}) do listed[l.key] = true end

    local out = {}
    for _, p in ipairs(owned or {}) do
        if not listed[p.prop_key] then
            out[#out + 1] = { key = p.prop_key, label = p.label }
        end
    end
    cb(out)
end)

-- Выставить бизнес на продажу
RegisterNetEvent('bu-realtor:server:list', function(key, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    key = tostring(key or '')
    price = tonumber(price)
    if not key or not price or price < 1 then return end

    local cid = Player.PlayerData.citizenid
    local prop = MySQL.query.await('SELECT prop_key, label, owner FROM bu_properties WHERE prop_key = ? LIMIT 1', { key })
    if not prop or not prop[1] then return end
    if prop[1].owner ~= cid then
        return TriggerClientEvent('QBCore:Notify', src, 'Это не твой бизнес.', 'error')
    end

    local already = MySQL.query.await('SELECT id FROM bu_listings WHERE `key` = ? LIMIT 1', { key })
    if already and already[1] then
        return TriggerClientEvent('QBCore:Notify', src, 'Уже выставлен на продажу.', 'error')
    end

    MySQL.insert('INSERT INTO bu_listings (owner, `key`, label, price) VALUES (?, ?, ?, ?)', { cid, key, prop[1].label, price })
    TriggerClientEvent('QBCore:Notify', src, 'Бизнес выставлен на продажу.', 'success')
end)

-- Снять с продажи
RegisterNetEvent('bu-realtor:server:unlist', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    key = tostring(key or '')
    MySQL.update('DELETE FROM bu_listings WHERE `key` = ? AND owner = ?', { key, Player.PlayerData.citizenid })
    TriggerClientEvent('QBCore:Notify', src, 'Объявление снято.', 'primary')
end)

-- Список выставленных бизнесов
QBCore.Functions.CreateCallback('bu-realtor:server:getListings', function(source, cb)
    local rows = MySQL.query.await('SELECT l.id, l.`key`, l.label, l.price, l.owner FROM bu_listings l ORDER BY l.id DESC LIMIT 30')
    cb(rows or {})
end)

-- Покупка бизнеса
RegisterNetEvent('bu-realtor:server:buy', function(listingId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    listingId = tonumber(listingId)

    local listing = MySQL.query.await('SELECT * FROM bu_listings WHERE id = ? LIMIT 1', { listingId })
    if not listing or not listing[1] then return end
    local item = listing[1]

    local buyerCid = Player.PlayerData.citizenid
    if item.owner == buyerCid then
        return TriggerClientEvent('QBCore:Notify', src, 'Это твой бизнес.', 'error')
    end

    if Player.Functions.GetMoney('bank') < item.price then
        return TriggerClientEvent('QBCore:Notify', src, 'Недостаточно средств на счёте.', 'error')
    end

    Player.Functions.RemoveMoney('bank', item.price, 'realtor-buy')

    local seller = QBCore.Functions.GetPlayerByCitizenId(item.owner)
    local payout = math.floor(item.price * (1 - Config.Commission))
    if seller then
        seller.Functions.AddMoney('bank', payout, 'realtor-sale')
        TriggerClientEvent('QBCore:Notify', seller.PlayerData.source, string.format('Бизнес продан за $%d.', item.price), 'success')
    end

    MySQL.update('UPDATE bu_properties SET owner = ? WHERE prop_key = ?', { buyerCid, item.key })
    MySQL.update('DELETE FROM bu_listings WHERE id = ?', { listingId })
    TriggerClientEvent('QBCore:Notify', src, 'Бизнес куплен!', 'success')
end)
