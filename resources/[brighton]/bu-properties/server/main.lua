local QBCore = exports['qb-core']:GetCoreObject()

local propertiesCache = {} -- propKey -> { key, label, owner, price }

local function loadProperties()
    MySQL.query('SELECT * FROM bu_properties', {}, function(result)
        if not result then return end
        for i = 1, #result do
            local row = result[i]
            propertiesCache[row.prop_key] = {
                key = row.prop_key,
                label = row.label,
                owner = row.owner or '',
                price = row.price
            }
        end
    end)
end

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_properties` (
            `prop_key` varchar(64) NOT NULL,
            `label` varchar(64) NOT NULL DEFAULT '',
            `owner` varchar(50) NOT NULL DEFAULT '',
            `price` int(11) NOT NULL DEFAULT 0,
            `supplies` int(11) NOT NULL DEFAULT 0,
            `drop_x` float NOT NULL DEFAULT 0,
            `drop_y` float NOT NULL DEFAULT 0,
            `drop_z` float NOT NULL DEFAULT 0,
            PRIMARY KEY (`prop_key`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]], {}, function()
            MySQL.query('ALTER TABLE `bu_properties` ADD COLUMN IF NOT EXISTS `supplies` int(11) NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS `drop_x` float NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS `drop_y` float NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS `drop_z` float NOT NULL DEFAULT 0')
            loadProperties()
        end)
    end)
end)

local function getProperty(key)
    if not propertiesCache[key] then
        local config = Config.Properties[key]
        if not config then return nil end
        local result = MySQL.query.await('SELECT * FROM bu_properties WHERE prop_key = ? LIMIT 1', { key })
        propertiesCache[key] = result and result[1] and {
            key = result[1].prop_key,
            label = result[1].label,
            owner = result[1].owner or '',
            price = result[1].price
        } or { key = key, label = config.label, owner = '', price = config.price }
    end
    return propertiesCache[key]
end

local function saveProperty(property)
    local config = Config.Properties[property.key]
    local dropX = config and config.coords.x or 0
    local dropY = config and config.coords.y or 0
    local dropZ = config and config.coords.z or 0
    MySQL.insert('INSERT INTO bu_properties (prop_key, label, owner, price, drop_x, drop_y, drop_z) VALUES (?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE owner = VALUES(owner), label = VALUES(label), price = VALUES(price), drop_x = VALUES(drop_x), drop_y = VALUES(drop_y), drop_z = VALUES(drop_z)', {
        property.key, property.label, property.owner, property.price, dropX, dropY, dropZ
    })
end

-- ============================================================
-- Экспорты для маркетплейса
-- ============================================================

exports('IsOwner', function(key, cid)
    if key and key:sub(1, 6) == 'house:' then
        local houseId = key:sub(7)
        local result = MySQL.query.await('SELECT 1 FROM player_houses WHERE house = ? AND citizenid = ? LIMIT 1', { houseId, cid })
        return result and result[1] ~= nil
    end

    local property = getProperty(key)
    return property ~= nil and property.owner == cid
end)

exports('Transfer', function(key, newOwner)
    if key and key:sub(1, 6) == 'house:' then
        local houseId = key:sub(7)
        MySQL.update('UPDATE player_houses SET citizenid = ?, keyholders = ? WHERE house = ?', {
            newOwner, json.encode({ [1] = newOwner }), houseId
        })
        return true
    end

    local property = getProperty(key)
    if not property then return false end
    property.owner = newOwner
    saveProperty(property)
    return true
end)

exports('GetLabel', function(key)
    if key and key:sub(1, 6) == 'house:' then
        return 'Жилой дом (' .. key:sub(7) .. ')'
    end
    local property = getProperty(key)
    return property and property.label or key
end)

-- ============================================================
-- Покупка через маркер
-- ============================================================

QBCore.Functions.CreateCallback('bu-properties:server:getStates', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local cid = Player.PlayerData.citizenid
    local states = {}
    for key in pairs(Config.Properties) do
        local property = getProperty(key)
        states[key] = { owner = property.owner, owned = property.owner == cid, label = property.label, price = property.price }
    end
    cb(states)
end)

RegisterNetEvent('bu-properties:server:buy', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local property = getProperty(key)
    if not property then
        TriggerClientEvent('bu-properties:client:notify', src, 'Объект не найден.', 'error')
        return
    end
    if property.owner ~= '' then
        TriggerClientEvent('bu-properties:client:notify', src, 'Этот бизнес уже занят.', 'error')
        return
    end

    local bank = Player.PlayerData.money.bank
    if not bank or bank < property.price then
        TriggerClientEvent('bu-properties:client:notify', src, string.format('Нужно $%d на банковском счёте.', property.price), 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', property.price, 'property-buy-' .. key)
    property.owner = Player.PlayerData.citizenid
    saveProperty(property)

    TriggerClientEvent('bu-properties:client:notify', src, string.format('Ты стал владельцем: %s.', property.label), 'success')
    TriggerClientEvent('bu-properties:client:refreshStates', src)
end)

RegisterNetEvent('bu-properties:server:sellToState', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local property = getProperty(key)
    if not property then return end
    if property.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-properties:client:notify', src, 'Это не твой бизнес.', 'error')
        return
    end

    local refund = math.floor(property.price * Config.StateRefundPercent)
    property.owner = ''
    saveProperty(property)

    Player.Functions.AddMoney('bank', refund, 'property-sell-state-' .. key)
    TriggerClientEvent('bu-properties:client:notify', src, string.format('Бизнес продан государству за $%d.', refund), 'success')
    TriggerClientEvent('bu-properties:client:refreshStates', src)
end)

-- ============================================================
-- Товары: заказ поставки (дальнобойщик) и продажа товаров
-- ============================================================

local function getSupplies(key)
    local result = MySQL.query.await('SELECT supplies FROM bu_properties WHERE prop_key = ? LIMIT 1', { key })
    return result and result[1] and result[1].supplies or 0
end

RegisterNetEvent('bu-properties:server:orderSupplies', function(key, units)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local property = getProperty(key)
    if not property or property.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-properties:client:notify', src, 'Это не твой бизнес.', 'error')
        return
    end

    units = tonumber(units)
    if not units or units < 1 or units > Config.Supply.maxUnitsPerOrder or math.floor(units) ~= units then
        TriggerClientEvent('bu-properties:client:notify', src, string.format('Количество — от 1 до %d единиц.', Config.Supply.maxUnitsPerOrder), 'error')
        return
    end

    local price = Config.Supply.orderPricePerUnit * units
    local bank = Player.PlayerData.money.bank
    if not bank or bank < price then
        TriggerClientEvent('bu-properties:client:notify', src, string.format('Нужно $%d на банковском счёте.', price), 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', price, 'supply-order-' .. key)

    local ownerName = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or '')
    exports['bu-jobs']:createTruckerOrder(Player.PlayerData.citizenid, ownerName, key, property.label, units)

    TriggerClientEvent('bu-properties:client:notify', src, string.format('Поставка %d ед. заказана за $%d. Дальнобойщик привезёт товары на бизнес.', units, price), 'success')
end)

RegisterNetEvent('bu-properties:server:sellSupplies', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local property = getProperty(key)
    if not property or property.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-properties:client:notify', src, 'Это не твой бизнес.', 'error')
        return
    end

    local supplies = getSupplies(key)
    if supplies <= 0 then
        TriggerClientEvent('bu-properties:client:notify', src, 'Товаров нет. Закажи поставку.', 'error')
        return
    end

    local total = supplies * Config.Supply.sellPricePerUnit
    MySQL.update('UPDATE bu_properties SET supplies = 0 WHERE prop_key = ?', { key })
    Player.Functions.AddMoney('bank', total, 'supply-sell-' .. key)

    TriggerClientEvent('bu-properties:client:notify', src, string.format('Товары проданы: +$%d на счёт банка.', total), 'success')
end)

QBCore.Functions.CreateCallback('bu-properties:server:getSupplies', function(source, cb, key)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(0) end

    local property = getProperty(key)
    if not property or property.owner ~= Player.PlayerData.citizenid then return cb(0) end
    cb(getSupplies(key))
end)
