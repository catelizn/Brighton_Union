local QBCore = exports['qb-core']:GetCoreObject()

-- ============================================================
-- Маркетплейс
-- ============================================================

local marketConfig = {
    commission = 0.05,       -- комиссия площадки с продавца
    maxListingsPerPlayer = 10,
    maxPrice = 10000000,
    removeFee = 1000         -- платное снятие лота с предметом (Majestic: $1000)
}

local listings = {} -- id -> { id, seller, sellerName, item, amount, price, createdAt }
local listingsLoaded = false

local function loadListings()
    MySQL.query('SELECT * FROM bu_marketplace', {}, function(result)
        if not result then
            listingsLoaded = true
            return
        end
        for i = 1, #result do
            local row = result[i]
            listings[row.id] = {
                id = row.id,
                seller = row.seller,
                sellerName = row.seller_name,
                item = row.item,
                amount = row.amount,
                price = row.price,
                createdAt = row.created_at,
                lotType = row.lot_type or 'item',
                propertyKey = row.property_key or '',
                views = row.views or 0,
                favourites = json.decode(row.favourites or '[]') or {}
            }
        end
        listingsLoaded = true
    end)
end

local function updateOfflineBank(cid, delta)
    local result = MySQL.query.await('SELECT money FROM players WHERE citizenid = ? LIMIT 1', { cid })
    if not result or not result[1] or not result[1].money then return end

    local money = json.decode(result[1].money)
    if not money or type(money) ~= 'table' then return end

    money.bank = math.max(0, (money.bank or 0) + delta)
    MySQL.update('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(money), cid })
end

local function notifyPlayer(cid, message, notifyType)
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    if Player then
        TriggerClientEvent('bu-marketplace:client:notify', Player.PlayerData.source, message, notifyType or 'primary')
    end
end

QBCore.Functions.CreateCallback('bu-marketplace:server:getListings', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local cid = Player.PlayerData.citizenid
    local list = {}
    for _, listing in pairs(listings) do
        local common = {
            id = listing.id,
            price = listing.price,
            sellerName = listing.sellerName,
            createdAt = listing.createdAt,
            views = listing.views or 0,
            favouritesCount = #(listing.favourites or {}),
            isFavourite = false
        }
        for _, favCid in ipairs(listing.favourites or {}) do
            if favCid == cid then common.isFavourite = true end
        end

        if listing.lotType == 'property' then
            common.lotType = 'property'
            common.itemLabel = exports['bu-properties']:GetLabel(listing.propertyKey)
            common.amount = 1
        elseif listing.lotType == 'rentveh' then
            common.lotType = 'rentveh'
            common.itemLabel = listing.vehicleLabel or listing.item
            common.amount = listing.amount
            common.available = listing.renter == nil
        else
            local itemData = QBCore.Shared.Items[listing.item]
            common.lotType = 'item'
            common.item = listing.item
            common.itemLabel = itemData and itemData.label or listing.item
            common.image = itemData and itemData.image or ''
            common.amount = listing.amount
        end

        list[#list + 1] = common
    end

    table.sort(list, function(a, b) return a.id > b.id end)
    cb(list)
end)

QBCore.Functions.CreateCallback('bu-marketplace:server:getMyItems', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local list = {}
    local items = Player.PlayerData.items or {}
    for i = 1, #items do
        local item = items[i]
        if item and item.amount and item.amount > 0 then
            local itemData = QBCore.Shared.Items[item.name]
            if itemData and not itemData.unique and (itemData.weight or 0) > 0 then
                list[#list + 1] = {
                    name = item.name,
                    label = itemData.label,
                    image = itemData.image,
                    amount = item.amount
                }
            end
        end
    end

    local myListings = {}
    for _, listing in pairs(listings) do
        if listing.seller == Player.PlayerData.citizenid then
            myListings[#myListings + 1] = {
                id = listing.id,
                lotType = listing.lotType or 'item',
                item = listing.lotType == 'property' and exports['bu-properties']:GetLabel(listing.propertyKey) or listing.item,
                amount = listing.amount,
                price = listing.price
            }
        end
    end
    table.sort(myListings, function(a, b) return a.id > b.id end)

    -- Недвижимость игрока (бизнесы и дома) для выставления на продажу
    local properties = {}
    local businessResult = MySQL.query.await('SELECT prop_key, label FROM bu_properties WHERE owner = ?', { Player.PlayerData.citizenid })
    if businessResult then
        for i = 1, #businessResult do
            properties[#properties + 1] = { key = businessResult[i].prop_key, label = businessResult[i].label }
        end
    end
    local houseResult = MySQL.query.await('SELECT house FROM player_houses WHERE citizenid = ?', { Player.PlayerData.citizenid })
    if houseResult then
        for i = 1, #houseResult do
            properties[#properties + 1] = { key = 'house:' .. houseResult[i].house, label = 'Жилой дом (' .. houseResult[i].house .. ')' }
        end
    end

    -- Транспорт игрока для сдачи в аренду
    local vehicles = {}
    local vehicleResult = MySQL.query.await('SELECT plate, vehicle, garage FROM player_vehicles WHERE citizenid = ? AND state = 1 LIMIT 20', { Player.PlayerData.citizenid })
    if vehicleResult then
        for i = 1, #vehicleResult do
            local catalog = QBCore.Shared.Vehicles and QBCore.Shared.Vehicles[vehicleResult[i].vehicle]
            local label = vehicleResult[i].vehicle
            if catalog then label = (catalog.brand or '') .. ' ' .. (catalog.name or vehicleResult[i].vehicle) end
            vehicles[#vehicles + 1] = { plate = vehicleResult[i].plate, label = label }
        end
    end

    cb({ items = list, listings = myListings, properties = properties, vehicles = vehicles })
end)

RegisterNetEvent('bu-marketplace:server:create', function(itemName, amount, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local itemData = QBCore.Shared.Items[itemName]
    if not itemData or itemData.unique then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Этот предмет нельзя выставить.', 'error')
        return
    end

    amount = tonumber(amount)
    price = tonumber(price)
    if not amount or amount < 1 or math.floor(amount) ~= amount then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Укажи корректное количество.', 'error')
        return
    end
    if not price or price < 1 or math.floor(price) ~= price or price > marketConfig.maxPrice then
        TriggerClientEvent('bu-marketplace:client:notify', src, string.format('Цена должна быть от $1 до $%s.', tostring(marketConfig.maxPrice)), 'error')
        return
    end

    local myCount = 0
    for _, listing in pairs(listings) do
        if listing.seller == cid then myCount = myCount + 1 end
    end
    if myCount >= marketConfig.maxListingsPerPlayer then
        TriggerClientEvent('bu-marketplace:client:notify', src, string.format('Нельзя держать больше %d лотов.', marketConfig.maxListingsPerPlayer), 'error')
        return
    end

    local item = Player.Functions.GetItemByName(itemName)
    if not item or not item.amount or item.amount < amount then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'У тебя нет столько предметов.', 'error')
        return
    end

    Player.Functions.RemoveItem(itemName, amount, false, item.slot)

    local sellerName = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or '')
    local listingId = MySQL.insert.await('INSERT INTO bu_marketplace (seller, seller_name, item, amount, price) VALUES (?, ?, ?, ?, ?)', {
        cid, sellerName, itemName, amount, price
    })

    listings[listingId] = {
        id = listingId,
        seller = cid,
        sellerName = sellerName,
        item = itemName,
        amount = amount,
        price = price,
        createdAt = os.date('%d.%m.%Y %H:%M')
    }

    TriggerClientEvent('bu-marketplace:client:notify', src, 'Лот выставлен на маркетплейс.', 'success')
end)

RegisterNetEvent('bu-marketplace:server:createProperty', function(propKey, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    price = tonumber(price)
    if not price or price < 1 or math.floor(price) ~= price or price > marketConfig.maxPrice then
        TriggerClientEvent('bu-marketplace:client:notify', src, string.format('Цена должна быть от $1 до $%s.', tostring(marketConfig.maxPrice)), 'error')
        return
    end

    if not exports['bu-properties']:IsOwner(propKey, cid) then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Эта недвижимость не твоя.', 'error')
        return
    end

    local myCount = 0
    for _, listing in pairs(listings) do
        if listing.seller == cid then myCount = myCount + 1 end
    end
    if myCount >= marketConfig.maxListingsPerPlayer then
        TriggerClientEvent('bu-marketplace:client:notify', src, string.format('Нельзя держать больше %d лотов.', marketConfig.maxListingsPerPlayer), 'error')
        return
    end

    local label = exports['bu-properties']:GetLabel(propKey)
    local sellerName = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or '')

    local listingId = MySQL.insert.await('INSERT INTO bu_marketplace (seller, seller_name, item, amount, price, lot_type, property_key) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        cid, sellerName, propKey, 1, price, 'property', propKey
    })

    listings[listingId] = {
        id = listingId,
        seller = cid,
        sellerName = sellerName,
        item = propKey,
        amount = 1,
        price = price,
        createdAt = os.date('%d.%m.%Y %H:%M'),
        lotType = 'property',
        propertyKey = propKey
    }

    TriggerClientEvent('bu-marketplace:client:notify', src, string.format('«%s» выставлена на маркетплейс.', label), 'success')
end)

-- ============================================================
-- Аренда транспорта на маркетплейсе
-- ============================================================

RegisterNetEvent('bu-marketplace:server:createRental', function(plate, pricePerHour, hours)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    pricePerHour = tonumber(pricePerHour)
    hours = tonumber(hours)

    if not pricePerHour or pricePerHour < 100 or pricePerHour > 100000 then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Цена за час — от $100 до $100 000.', 'error')
        return
    end
    if not hours or hours < 1 or hours > 24 or math.floor(hours) ~= hours then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Срок аренды — от 1 до 24 часов.', 'error')
        return
    end

    local vehicleResult = MySQL.query.await('SELECT plate, vehicle, garage FROM player_vehicles WHERE citizenid = ? AND plate = ? AND state = 1 LIMIT 1', { cid, plate })
    if not vehicleResult or not vehicleResult[1] then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Машина не найдена или уже сдана.', 'error')
        return
    end

    local myCount = 0
    for _, listing in pairs(listings) do
        if listing.seller == cid then myCount = myCount + 1 end
    end
    if myCount >= marketConfig.maxListingsPerPlayer then
        TriggerClientEvent('bu-marketplace:client:notify', src, string.format('Нельзя держать больше %d лотов.', marketConfig.maxListingsPerPlayer), 'error')
        return
    end

    local catalog = QBCore.Shared.Vehicles and QBCore.Shared.Vehicles[vehicleResult[1].vehicle]
    local vehicleLabel = vehicleResult[1].vehicle
    if catalog then vehicleLabel = (catalog.brand or '') .. ' ' .. (catalog.name or vehicleResult[1].vehicle) end

    local sellerName = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or '')

    MySQL.update('UPDATE player_vehicles SET state = 2, garage = ? WHERE plate = ? AND citizenid = ?', { 'RENT', plate, cid })

    local listingId = MySQL.insert.await('INSERT INTO bu_marketplace (seller, seller_name, item, amount, price, lot_type, property_key) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        cid, sellerName, plate, hours, pricePerHour, 'rentveh', vehicleResult[1].garage
    })

    listings[listingId] = {
        id = listingId,
        seller = cid,
        sellerName = sellerName,
        item = plate,
        amount = hours,
        price = pricePerHour,
        createdAt = os.date('%d.%m.%Y %H:%M'),
        lotType = 'rentveh',
        propertyKey = vehicleResult[1].garage,
        vehicleLabel = vehicleLabel,
        vehicleModel = vehicleResult[1].vehicle,
        renter = nil,
        rentUntil = 0
    }

    TriggerClientEvent('bu-marketplace:client:notify', src, string.format('%s (%s) сдана в аренду за $%d/час.', vehicleLabel, plate, pricePerHour), 'success')
end)

RegisterNetEvent('bu-marketplace:server:rentVehicle', function(listingId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local listing = listings[tonumber(listingId)]
    if not listing or listing.lotType ~= 'rentveh' then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Лот не найден.', 'error')
        return
    end
    if listing.seller == Player.PlayerData.citizenid then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Это твоя машина.', 'error')
        return
    end
    if listing.renter then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Машина уже в аренде.', 'error')
        return
    end
    if exports['bu-rental']:getActiveRental(Player.PlayerData.citizenid) then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Сначала верни текущий арендованный транспорт.', 'error')
        return
    end

    local total = listing.price * listing.amount
    local bank = Player.PlayerData.money.bank
    if not bank or bank < total then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Недостаточно средств на банковском счёте.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', total, 'market-rent-' .. listing.id)

    local commission = math.floor(total * marketConfig.commission)
    local payout = total - commission

    local Seller = QBCore.Functions.GetPlayerByCitizenId(listing.seller)
    if Seller then
        Seller.Functions.AddMoney('bank', payout, 'market-rent-income-' .. listing.id)
    else
        updateOfflineBank(listing.seller, payout)
    end

    listing.renter = Player.PlayerData.citizenid
    listing.rentUntil = os.time() + listing.amount * 3600

    exports['bu-rental']:addExternalRental(Player.PlayerData.citizenid, listing.vehicleModel, listing.vehicleLabel, 'RENT' .. math.random(100, 999), listing.amount)

    notifyPlayer(listing.seller, string.format('Твоя машина в аренде: +$%d на счёт (комиссия $%d).', payout, commission), 'success')
    TriggerClientEvent('bu-marketplace:client:notify', src, string.format('Аренда началась на %d ч. Машина у тебя, таймер — в приложении «Аренда».', listing.amount), 'success')
end)

-- Автовозврат: срок аренды истёк — машина снимается и возвращается владельцу
CreateThread(function()
    while true do
        Wait(30000)
        local now = os.time()
        for _, listing in pairs(listings) do
            if listing.lotType == 'rentveh' and listing.renter and listing.rentUntil > 0 and now >= listing.rentUntil then
                exports['bu-rental']:finishRental(listing.renter)

                MySQL.update('UPDATE player_vehicles SET state = 1, garage = ? WHERE plate = ? AND citizenid = ?', {
                    listing.propertyKey or 'c', listing.item, listing.seller
                })

                notifyPlayer(listing.renter, 'Время аренды истекло, машина возвращена владельцу.', 'error')
                notifyPlayer(listing.seller, 'Аренда завершена, машина снова в твоём гараже.', 'inform')

                listings[listing.id] = nil
                MySQL.query('DELETE FROM bu_marketplace WHERE id = ?', { listing.id })
            end
        end
    end
end)

RegisterNetEvent('bu-marketplace:server:buy', function(listingId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local listing = listings[tonumber(listingId)]
    if not listing then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Лот уже не существует.', 'error')
        return
    end
    if listing.seller == Player.PlayerData.citizenid then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Нельзя купить собственный лот.', 'error')
        return
    end

    local bank = Player.PlayerData.money.bank
    if not bank or bank < listing.price then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Недостаточно средств на банковском счёте.', 'error')
        return
    end

    if listing.lotType == 'property' then
        if exports['bu-properties']:IsOwner(listing.propertyKey, Player.PlayerData.citizenid) then
            TriggerClientEvent('bu-marketplace:client:notify', src, 'У тебя уже есть эта недвижимость.', 'error')
            return
        end

        listings[listing.id] = nil
        MySQL.query('DELETE FROM bu_marketplace WHERE id = ?', { listing.id })

        Player.Functions.RemoveMoney('bank', listing.price, 'marketplace-buy-' .. listing.id)

        local commission = math.floor(listing.price * marketConfig.commission)
        local payout = listing.price - commission

        exports['bu-properties']:Transfer(listing.propertyKey, Player.PlayerData.citizenid)

        local Seller = QBCore.Functions.GetPlayerByCitizenId(listing.seller)
        if Seller then
            Seller.Functions.AddMoney('bank', payout, 'marketplace-sell-' .. listing.id)
        else
            updateOfflineBank(listing.seller, payout)
        end

        notifyPlayer(listing.seller, string.format('Продана недвижимость «%s» за $%d. На счёт зачислено $%d (комиссия $%d).', exports['bu-properties']:GetLabel(listing.propertyKey), listing.price, payout, commission), 'success')
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Покупка успешна. Недвижимость теперь твоя.', 'success')
        return
    end

    local added = Player.Functions.AddItem(listing.item, listing.amount, false)
    if not added then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Твой инвентарь полон.', 'error')
        return
    end

    listings[listing.id] = nil
    MySQL.query('DELETE FROM bu_marketplace WHERE id = ?', { listing.id })

    Player.Functions.RemoveMoney('bank', listing.price, 'marketplace-buy-' .. listing.id)

    local commission = math.floor(listing.price * marketConfig.commission)
    local payout = listing.price - commission

    local Seller = QBCore.Functions.GetPlayerByCitizenId(listing.seller)
    if Seller then
        Seller.Functions.AddMoney('bank', payout, 'marketplace-sell-' .. listing.id)
    else
        updateOfflineBank(listing.seller, payout)
    end

    notifyPlayer(listing.seller, string.format('Продан лот «%s» за $%d. На счёт зачислено $%d (комиссия $%d).', QBCore.Shared.Items[listing.item].label, listing.price, payout, commission), 'success')
    TriggerClientEvent('bu-marketplace:client:notify', src, 'Покупка успешна. Предметы уже в инвентаре.', 'success')
end)

RegisterNetEvent('bu-marketplace:server:cancel', function(listingId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local listing = listings[tonumber(listingId)]
    if not listing then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Лот уже не существует.', 'error')
        return
    end
    if listing.seller ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Это не твой лот.', 'error')
        return
    end

    local lotType = listing.lotType or 'item'

    -- Снятие лота с предметом платное (Majestic: $1000), имущество — бесплатно
    if lotType == 'item' and marketConfig.removeFee > 0 then
        if not Player.Functions.RemoveMoney('bank', marketConfig.removeFee, 'marketplace-remove-fee') then
            TriggerClientEvent('bu-marketplace:client:notify', src, string.format('Снятие лота стоит $%d (оплата с банка).', marketConfig.removeFee), 'error')
            return
        end
        TriggerClientEvent('bu-marketplace:client:notify', src, string.format('Списана плата за снятие: $%d.', marketConfig.removeFee), 'inform')
    end

    listings[listing.id] = nil
    MySQL.query('DELETE FROM bu_marketplace WHERE id = ?', { listing.id })

    if lotType == 'item' then
        Player.Functions.AddItem(listing.item, listing.amount, false)
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Лот снят, предметы возвращены.', 'success')
    elseif lotType == 'rentveh' then
        MySQL.update('UPDATE player_vehicles SET state = 1 WHERE plate = ?', { listing.item })
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Лот снят, машина возвращена в гараж.', 'success')
    else
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Лот снят.', 'success')
    end
end)

-- Просмотр лота: счётчик на карточке (Majestic)
RegisterNetEvent('bu-marketplace:server:view', function(listingId)
    local listing = listings[tonumber(listingId)]
    if not listing then return end
    listing.views = (listing.views or 0) + 1
    MySQL.update('UPDATE bu_marketplace SET views = ? WHERE id = ?', { listing.views, listing.id })
end)

-- Избранное: включить/выключить
RegisterNetEvent('bu-marketplace:server:toggleFavourite', function(listingId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local listing = listings[tonumber(listingId)]
    if not listing then return end

    local favourites = listing.favourites or {}
    local cid = Player.PlayerData.citizenid
    local found = false
    for i, favCid in ipairs(favourites) do
        if favCid == cid then
            table.remove(favourites, i)
            found = true
            break
        end
    end
    if not found then
        favourites[#favourites + 1] = cid
    end

    listing.favourites = favourites
    MySQL.update('UPDATE bu_marketplace SET favourites = ? WHERE id = ?', { json.encode(favourites), listing.id })
    TriggerClientEvent('bu-marketplace:client:notify', src, found and 'Убрано из избранного.' or 'Добавлено в избранное.', 'success')
end)

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_marketplace` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `seller` varchar(50) NOT NULL,
            `seller_name` varchar(64) NOT NULL DEFAULT '',
            `item` varchar(50) NOT NULL,
            `amount` int(11) NOT NULL DEFAULT 1,
            `price` int(11) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `idx_seller` (`seller`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]], {}, function()
            MySQL.query("ALTER TABLE bu_marketplace ADD COLUMN IF NOT EXISTS lot_type varchar(16) NOT NULL DEFAULT 'item', ADD COLUMN IF NOT EXISTS property_key varchar(64) NOT NULL DEFAULT ''", {}, function()
                MySQL.query("ALTER TABLE bu_marketplace ADD COLUMN IF NOT EXISTS views int(11) NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS favourites text", {}, function()
                    loadListings()
                end)
            end)
        end)
    end)
end)

-- ============================================================
-- Данные планшета
-- ============================================================

QBCore.Functions.CreateCallback('bu-tablet:server:getData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local playerData = Player.PlayerData
    local charinfo = playerData.charinfo or {}

    local licenses = {}
    for i = 1, #Config.Documents do
        local doc = Config.Documents[i]
        local item = Player.Functions.GetItemByName(doc.item)
        if item then
            local category = ''
            if doc.item == 'driver_license' and item.info and item.info.type then
                local raw = item.info.type
                if raw:find(',') then
                    local parts = {}
                    for cat in raw:gmatch('[^,]+') do
                        parts[#parts + 1] = Config.CategoryNames[cat] or cat
                    end
                    category = 'Категории: ' .. table.concat(parts, ', ')
                else
                    category = Config.DriverCategories[raw] or ''
                end
            end
            licenses[#licenses + 1] = {
                label = doc.label,
                icon = doc.icon,
                category = category
            }
        end
    end

    local vehicles = {}
    local result = MySQL.query.await('SELECT vehicle, plate, garage FROM player_vehicles WHERE citizenid = ? AND state = 1 LIMIT 20', { playerData.citizenid })
    if result then
        for i = 1, #result do
            local vehicleData = result[i]
            local catalog = QBCore.Shared.Vehicles and QBCore.Shared.Vehicles[vehicleData.vehicle]
            local label = vehicleData.vehicle
            if catalog then
                label = (catalog.brand or '') .. ' ' .. (catalog.name or vehicleData.vehicle)
            end
            vehicles[#vehicles + 1] = {
                label = label,
                plate = vehicleData.plate,
                garage = vehicleData.garage or 'Город'
            }
        end
    end

    cb({
        charinfo = {
            firstname = charinfo.firstname,
            lastname = charinfo.lastname,
            birthdate = charinfo.birthdate,
            nationality = charinfo.nationality,
            gender = charinfo.gender
        },
        photoDate = playerData.metadata and playerData.metadata.photodate or nil,
        job = playerData.job and playerData.job.label or 'Безработный',
        money = {
            cash = playerData.money and playerData.money.cash or 0,
            bank = playerData.money and playerData.money.bank or 0
        },
        licenses = licenses,
        vehicles = vehicles
    })
end)

-- ============================================================
-- Даркнет: теневой маркет, заказ забирается в точке выдачи
-- ============================================================

local darknetOrders = {}   -- citizenid -> { item, label, orderedAt }
local darknetCooldowns = {} -- citizenid -> os.time()

QBCore.Functions.CreateCallback('bu-darknet:server:getCatalog', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local cid = Player.PlayerData.citizenid
    local now = os.time()
    local cooldownLeft = 0
    if darknetCooldowns[cid] and now - darknetCooldowns[cid] < Config.Darknet.cooldownMinutes * 60 then
        cooldownLeft = Config.Darknet.cooldownMinutes * 60 - (now - darknetCooldowns[cid])
    end

    local order = darknetOrders[cid]
    cb({
        items = Config.Darknet.items,
        pickup = Config.Darknet.pickup,
        cooldownLeft = cooldownLeft,
        pending = order and { item = order.item, label = order.label } or nil
    })
end)

RegisterNetEvent('bu-darknet:server:buy', function(itemId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local item = nil
    for i = 1, #Config.Darknet.items do
        if Config.Darknet.items[i].id == itemId then
            item = Config.Darknet.items[i]
        end
    end
    if not item then return end

    local cid = Player.PlayerData.citizenid
    local now = os.time()
    if darknetCooldowns[cid] and now - darknetCooldowns[cid] < Config.Darknet.cooldownMinutes * 60 then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Даркнет: между заказами нужно подождать.', 'error')
        return
    end
    if darknetOrders[cid] then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Забери предыдущий заказ в точке выдачи.', 'error')
        return
    end

    local cash = Player.PlayerData.money.cash
    if not cash or cash < item.price then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Не хватает наличных.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', item.price, 'darknet-order')
    darknetOrders[cid] = { item = item.id, label = item.label, orderedAt = now }
    darknetCooldowns[cid] = now

    TriggerClientEvent('bu-marketplace:client:notify', src, 'Заказ принят. Точка выдачи отмечена на карте — забери товар.', 'success')
end)

RegisterNetEvent('bu-darknet:server:pickup', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local order = darknetOrders[cid]
    if not order then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'У тебя нет активных заказов.', 'error')
        return
    end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - Config.Darknet.pickup) > 15.0 then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Подойди к точке выдачи.', 'error')
        return
    end

    local added = Player.Functions.AddItem(order.item, 1, false)
    if not added then
        TriggerClientEvent('bu-marketplace:client:notify', src, 'Инвентарь полон — освободи место и попробуй снова.', 'error')
        return
    end

    darknetOrders[cid] = nil
    TriggerClientEvent('bu-marketplace:client:notify', src, order.label .. ' получен.', 'success')
end)
