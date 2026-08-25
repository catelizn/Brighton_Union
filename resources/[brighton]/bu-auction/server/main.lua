local QBCore = exports['qb-core']:GetCoreObject()

local auctions = {} -- id -> lot
local nextId = 1

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_auctions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `seller` varchar(50) NOT NULL,
            `seller_name` varchar(64) NOT NULL DEFAULT '',
            `lot_type` varchar(16) NOT NULL,
            `lot_key` varchar(64) NOT NULL,
            `label` varchar(64) NOT NULL DEFAULT '',
            `start_price` int(11) NOT NULL DEFAULT 0,
            `current_bid` int(11) NOT NULL DEFAULT 0,
            `bidder` varchar(50) NOT NULL DEFAULT '',
            `bidder_name` varchar(64) NOT NULL DEFAULT '',
            `ends_at` int(11) NOT NULL DEFAULT 0,
            `status` varchar(16) NOT NULL DEFAULT 'open',
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

local function auctionNotify(cid, message, notifyType)
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    if Player then
        TriggerClientEvent('bu-auction:client:notify', Player.PlayerData.source, message, notifyType or 'primary')
    end
end

local function finishAuction(id)
    local lot = auctions[id]
    if not lot or lot.status ~= 'open' then return end

    lot.status = 'done'

    if lot.bidder and lot.bidder ~= '' then
        local winner = QBCore.Functions.GetPlayerByCitizenId(lot.bidder)
        if winner then
            if winner.PlayerData.money.bank < lot.currentBid then
                auctionNotify(lot.bidder, 'На аукционе не хватило средств — ставка снята.', 'error')
                lot.bidder = ''
                lot.status = 'no-bid'
            end
        end
    end

    if lot.status == 'done' and lot.bidder and lot.bidder ~= '' then
        local winner = QBCore.Functions.GetPlayerByCitizenId(lot.bidder)
        if winner then
            winner.Functions.RemoveMoney('bank', lot.currentBid, 'auction-win-' .. id)
        end

        if lot.lotType == 'business' then
            exports['bu-properties']:Transfer(lot.lotKey, lot.bidder)
        elseif lot.lotType == 'house' then
            local houseId = lot.lotKey:sub(7)
            MySQL.update('UPDATE player_houses SET citizenid = ?, keyholders = ? WHERE house = ?', {
                lot.bidder, json.encode({ [1] = lot.bidder }), houseId
            })
        elseif lot.lotType == 'apartment' then
            MySQL.update('UPDATE bu_apartments SET owner = ? WHERE id = ?', { lot.bidder, tonumber(lot.lotKey) })
        elseif lot.lotType == 'vehicle' then
            MySQL.update('UPDATE player_vehicles SET citizenid = ?, state = 1, garage = ? WHERE plate = ? AND citizenid = ?', {
                lot.bidder, 'Город', lot.lotKey, lot.seller
            })
        elseif lot.lotType == 'item' then
            if winner then
                winner.Functions.AddItem(lot.itemName, lot.itemAmount, false, lot.itemInfo)
            end
        end

        local commission = math.floor(lot.currentBid * Config.Commission)
        local payout = lot.currentBid - commission
        local seller = QBCore.Functions.GetPlayerByCitizenId(lot.seller)
        if seller then
            seller.Functions.AddMoney('bank', payout, 'auction-sell-' .. id)
        else
            local result = MySQL.query.await('SELECT money FROM players WHERE citizenid = ? LIMIT 1', { lot.seller })
            if result and result[1] and result[1].money then
                local money = json.decode(result[1].money)
                if money and type(money) == 'table' then
                    money.bank = math.max(0, (money.bank or 0) + payout)
                    MySQL.update('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(money), lot.seller })
                end
            end
        end

        auctionNotify(lot.bidder, string.format('Ты выиграл лот «%s» за $%d.', lot.label, lot.currentBid), 'success')
        auctionNotify(lot.seller, string.format('Лот «%s» продан за $%d. На счёт зачислено $%d (комиссия $%d).', lot.label, lot.currentBid, payout, commission), 'success')
    else
        -- Возврат лота продавцу, если ставок не было
        if lot.lotType == 'item' then
            local seller = QBCore.Functions.GetPlayerByCitizenId(lot.seller)
            if seller then
                seller.Functions.AddItem(lot.itemName, lot.itemAmount, false, lot.itemInfo)
            end
        elseif lot.lotType == 'vehicle' then
            MySQL.update('UPDATE player_vehicles SET state = 1 WHERE plate = ? AND citizenid = ?', { lot.lotKey, lot.seller })
        end
        auctionNotify(lot.seller, string.format('Аукцион «%s» завершён без ставок. Лот возвращён.', lot.label), 'inform')
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        local now = os.time()
        for id, lot in pairs(auctions) do
            if lot.status == 'open' and now >= lot.endsAt then
                finishAuction(id)
            end
        end
    end
end)

QBCore.Functions.CreateCallback('bu-auction:server:getAuctions', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local list = {}
    for id, lot in pairs(auctions) do
        if lot.status == 'open' then
            list[#list + 1] = {
                id = id,
                lotType = lot.lotType,
                label = lot.label,
                startPrice = lot.startPrice,
                currentBid = lot.currentBid,
                bidderName = lot.bidderName,
                endsAt = lot.endsAt,
                isMine = lot.seller == Player.PlayerData.citizenid
            }
        end
    end
    table.sort(list, function(a, b) return a.endsAt < b.endsAt end)
    cb(list)
end)

RegisterNetEvent('bu-auction:server:create', function(lotType, lotKey, label, startPrice, duration, itemName, itemAmount, itemInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    lotType = tostring(lotType)
    startPrice = tonumber(startPrice)
    duration = tonumber(duration) or Config.DefaultDuration
    if not startPrice or startPrice < 1000 or startPrice > 10000000 then
        TriggerClientEvent('bu-auction:client:notify', src, 'Стартовая цена — от $1 000 до $10 000 000.', 'error')
        return
    end
    if duration < 60 or duration > 3600 then
        TriggerClientEvent('bu-auction:client:notify', src, 'Длительность — от 1 до 60 минут.', 'error')
        return
    end

    local cid = Player.PlayerData.citizenid

    if lotType == 'business' then
        if not exports['bu-properties']:IsOwner(lotKey, cid) then
            TriggerClientEvent('bu-auction:client:notify', src, 'Этот бизнес не твой.', 'error')
            return
        end
        label = exports['bu-properties']:GetLabel(lotKey)
    elseif lotType == 'house' then
        local houseId = tostring(lotKey):sub(7)
        local owned = MySQL.query.await('SELECT 1 FROM player_houses WHERE house = ? AND citizenid = ? LIMIT 1', { houseId, cid })
        if not owned or not owned[1] then
            TriggerClientEvent('bu-auction:client:notify', src, 'Этот дом не твой.', 'error')
            return
        end
        label = 'Жилой дом (' .. houseId .. ')'
    elseif lotType == 'apartment' then
        local flat = MySQL.query.await('SELECT id, building, number FROM bu_apartments WHERE id = ? AND owner = ? LIMIT 1', { tonumber(lotKey), cid })
        if not flat or not flat[1] then
            TriggerClientEvent('bu-auction:client:notify', src, 'Эта квартира не твоя.', 'error')
            return
        end
        label = string.format('Квартира №%d (%s)', flat[1].number, flat[1].building)
    elseif lotType == 'vehicle' then
        local vehicle = MySQL.query.await('SELECT plate, vehicle FROM player_vehicles WHERE plate = ? AND citizenid = ? AND state = 1 LIMIT 1', { lotKey, cid })
        if not vehicle or not vehicle[1] then
            TriggerClientEvent('bu-auction:client:notify', src, 'Машина не найдена или уже выставлена.', 'error')
            return
        end
        label = label or vehicle[1].vehicle
        MySQL.update('UPDATE player_vehicles SET state = 2, garage = ? WHERE plate = ? AND citizenid = ?', { 'AUCTION', lotKey, cid })
    elseif lotType == 'item' then
        local item = Player.Functions.GetItemByName(itemName)
        if not item or not item.amount or item.amount < (tonumber(itemAmount) or 1) then
            TriggerClientEvent('bu-auction:client:notify', src, 'Предмета нет в инвентаре.', 'error')
            return
        end
        itemInfo = item.info
        Player.Functions.RemoveItem(itemName, tonumber(itemAmount), false, item.slot)
        label = label or (QBCore.Shared.Items[itemName] and QBCore.Shared.Items[itemName].label or itemName)
    else
        return
    end

    local sellerName = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or '')

    local id = nextId
    nextId = nextId + 1
    auctions[id] = {
        id = id,
        seller = cid,
        sellerName = sellerName,
        lotType = lotType,
        lotKey = lotKey,
        label = label,
        startPrice = startPrice,
        currentBid = 0,
        bidder = '',
        bidderName = '',
        endsAt = os.time() + duration,
        status = 'open',
        itemName = itemName,
        itemAmount = tonumber(itemAmount) or 1,
        itemInfo = itemInfo
    }

    TriggerClientEvent('bu-auction:client:notify', src, string.format('Лот «%s» выставлен на аукцион.', label), 'success')
end)

RegisterNetEvent('bu-auction:server:bid', function(auctionId, multiplier)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local lot = auctions[tonumber(auctionId)]
    if not lot or lot.status ~= 'open' then
        TriggerClientEvent('bu-auction:client:notify', src, 'Аукцион не найден.', 'error')
        return
    end
    if lot.seller == Player.PlayerData.citizenid then
        TriggerClientEvent('bu-auction:client:notify', src, 'Нельзя ставить на свой лот.', 'error')
        return
    end
    if lot.bidder == Player.PlayerData.citizenid then
        TriggerClientEvent('bu-auction:client:notify', src, 'Твоя ставка уже максимальная.', 'error')
        return
    end

    multiplier = tonumber(multiplier)
    if multiplier ~= 3 and multiplier ~= 5 then multiplier = 1 end

    -- Ставка = текущая (или стартовая) + шаг × множитель
    local base = math.max(lot.startPrice, lot.currentBid)
    local step = math.max(1, math.floor(base * Config.MinBidStep))
    local bid = base + step * multiplier

    local bank = Player.PlayerData.money.bank
    if not bank or bank < bid then
        TriggerClientEvent('bu-auction:client:notify', src, string.format('Для ставки нужно $%d на банковском счёте.', bid), 'error')
        return
    end

    lot.currentBid = bid
    lot.bidder = Player.PlayerData.citizenid
    lot.bidderName = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or '')

    -- Антиснайп: ставка под конец продлевает торги
    if Config.AntisnipeSeconds > 0 and lot.endsAt - os.time() < Config.AntisnipeSeconds then
        lot.endsAt = os.time() + Config.AntisnipeSeconds
        TriggerClientEvent('bu-auction:client:notify', src, 'Ставка на последней минуте — торги продлены.', 'inform')
    end

    TriggerClientEvent('bu-auction:client:notify', src, string.format('Ставка принята: $%d.', bid), 'success')
    auctionNotify(lot.seller, string.format('Новая ставка по лоту «%s»: $%d.', lot.label, bid), 'inform')
end)

-- Данные для выставления лотов: недвижимость, машины, предметы
QBCore.Functions.CreateCallback('bu-auction:server:getMyLots', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local cid = Player.PlayerData.citizenid
    local properties = {}
    local houses = {}
    local apartments = {}
    local vehicles = {}
    local items = {}

    local businessResult = MySQL.query.await('SELECT prop_key, label FROM bu_properties WHERE owner = ?', { cid })
    if businessResult then
        for i = 1, #businessResult do
            properties[#properties + 1] = { key = businessResult[i].prop_key, label = businessResult[i].label }
        end
    end
    local houseResult = MySQL.query.await('SELECT house FROM player_houses WHERE citizenid = ?', { cid })
    if houseResult then
        for i = 1, #houseResult do
            houses[#houses + 1] = { key = 'house:' .. houseResult[i].house, label = 'Жилой дом (' .. houseResult[i].house .. ')' }
        end
    end
    local flatResult = MySQL.query.await('SELECT id, building, number FROM bu_apartments WHERE owner = ?', { cid })
    if flatResult then
        for i = 1, #flatResult do
            apartments[#apartments + 1] = { key = tostring(flatResult[i].id), label = string.format('Квартира №%d (%s)', flatResult[i].number, flatResult[i].building) }
        end
    end
    local vehicleResult = MySQL.query.await('SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ? AND state = 1 LIMIT 20', { cid })
    if vehicleResult then
        for i = 1, #vehicleResult do
            local catalog = QBCore.Shared.Vehicles and QBCore.Shared.Vehicles[vehicleResult[i].vehicle]
            local label = vehicleResult[i].vehicle
            if catalog then label = (catalog.brand or '') .. ' ' .. (catalog.name or vehicleResult[i].vehicle) end
            vehicles[#vehicles + 1] = { key = vehicleResult[i].plate, label = label .. ' (' .. vehicleResult[i].plate .. ')' }
        end
    end
    for i = 1, #(Player.PlayerData.items or {}) do
        local item = Player.PlayerData.items[i]
        if item and item.amount and item.amount > 0 then
            local itemData = QBCore.Shared.Items[item.name]
            if itemData and not itemData.unique and (itemData.weight or 0) > 0 then
                items[#items + 1] = { name = item.name, label = itemData.label, amount = item.amount }
            end
        end
    end

    cb({ properties = properties, houses = houses, apartments = apartments, vehicles = vehicles, items = items })
end)
