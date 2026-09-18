local QBCore = exports['qb-core']:GetCoreObject()

-- Кэш прогресса: citizenid -> { [job] = { level, xp } }
local progressCache = {}
-- Антиспам: citizenid -> os.clock() последнего действия
local cooldowns = {}

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_job_progress` (
            `citizenid` varchar(50) NOT NULL,
            `job` varchar(32) NOT NULL,
            `level` int(11) NOT NULL DEFAULT 0,
            `xp` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`citizenid`, `job`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    progressCache[Player.PlayerData.citizenid] = nil
    cooldowns[src] = nil
end)

local function loadJobProgress(cid, job)
    progressCache[cid] = progressCache[cid] or {}
    if not progressCache[cid][job] then
        local result = MySQL.query.await('SELECT level, xp FROM bu_job_progress WHERE citizenid = ? AND job = ? LIMIT 1', { cid, job })
        progressCache[cid][job] = result and result[1] and { level = result[1].level, xp = result[1].xp } or { level = 0, xp = 0 }
    end
    return progressCache[cid][job]
end

local function saveJobProgress(cid, job, entry)
    MySQL.insert('INSERT INTO bu_job_progress (citizenid, job, level, xp) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE level = VALUES(level), xp = VALUES(xp)', {
        cid, job, entry.level, entry.xp
    })
end

local function addProgress(cid, job, xp)
    local entry = loadJobProgress(cid, job)
    local leveledUp = false

    entry.xp = entry.xp + xp
    while entry.xp >= Config.XpPerLevel and entry.level < Config.MaxLevel do
        entry.xp = entry.xp - Config.XpPerLevel
        entry.level = entry.level + 1
        leveledUp = true
    end
    if entry.level >= Config.MaxLevel then
        entry.xp = math.min(entry.xp, Config.XpPerLevel - 1)
    end

    saveJobProgress(cid, job, entry)
    return entry.level, leveledUp
end

local function payForAction(Player, src, jobKey)
    local job = Config.Jobs[jobKey]
    local level, leveledUp = addProgress(Player.PlayerData.citizenid, jobKey, job.xp)
    local multiplier = Config.PayMultipliers[level] or 1.0
    local pay = math.floor(job.basePay * multiplier)

    Player.Functions.AddMoney('cash', pay, 'job-' .. jobKey)

    -- Опыт боевого пропуска за действие
    local bp = exports['bu-battlepass']
    if bp and bp.addXp then
        pcall(function() bp.addXp(Player.PlayerData.citizenid, 10) end)
    end

    -- Заработок учитывается в цепочке новичка (этап «заработай $1000»)
    TriggerEvent('bu-tutorial:server:jobEarned', Player.PlayerData.citizenid, pay)

    local message = string.format('%s: +$%d, опыт +%d. Уровень %d/10.', job.label, pay, job.xp, level)
    if leveledUp then
        message = message .. ' Новый уровень!'
    end
    TriggerClientEvent('bu-jobs:client:notify', src, message, 'success')
end

local function isCooldown(src)
    local now = os.clock()
    if cooldowns[src] and now - cooldowns[src] < Config.GatherCooldown then
        return true
    end
    cooldowns[src] = now
    return false
end

local function checkJob(Player, src, jobKey, job)
    if Player.PlayerData.job.name ~= jobKey then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Это не твоя работа. Устройся у NPC на месте работы.', 'error')
        return false
    end
    if job.license and not Player.Functions.GetItemByName(job.license) then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Нужна ' .. job.licenseLabel .. '.', 'error')
        return false
    end
    return true
end

-- Данные для диалога найма: оплата за действие и её рост от уровня
QBCore.Functions.CreateCallback('bu-jobs:server:getJobOffer', function(source, cb, jobKey)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    local job = Config.Jobs[jobKey]
    if not job then return cb(nil) end
    local level = loadJobProgress(Player.PlayerData.citizenid, jobKey).level or 0
    local multiplier = Config.PayMultipliers[level] or 1.0
    local maxMultiplier = Config.PayMultipliers[Config.MaxLevel] or 2.0
    cb({
        key = jobKey,
        label = job.label,
        basePay = job.basePay,
        level = level,
        currentPay = math.floor(job.basePay * multiplier),
        maxPay = math.floor(job.basePay * maxMultiplier)
    })
end)

-- Найм на работу: только у NPC на месте работы
RegisterNetEvent('bu-jobs:server:hire', function(jobKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Config.Jobs[jobKey]
    if not job or not job.hire then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    local hirePos = job.hire.coords
    if #(position - vec3(hirePos.x, hirePos.y, hirePos.z)) > 15.0 then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Подойди к NPC на месте работы.', 'error')
        return
    end

    if Player.PlayerData.job.name == jobKey then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Ты уже работаешь здесь.', 'error')
        return
    end

    Player.Functions.SetJob(jobKey, 0)
    TriggerClientEvent('bu-jobs:client:notify', src, 'Ты устроился на работу: ' .. job.label .. '. Смену можно начать через F6.', 'success')
end)

RegisterNetEvent('bu-jobs:server:gather', function(jobKey, zoneIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Config.Jobs[jobKey]
    if not job or not job.zones then return end
    if not checkJob(Player, src, jobKey, job) then return end
    if isCooldown(src) then return end

    local zone = job.zones[tonumber(zoneIndex) or 1]
    if not zone then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - zone.coords) > (zone.radius or Config.DefaultZoneRadius) then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Ты слишком далеко от места работы.', 'error')
        return
    end

    if zone.minLevel then
        local entry = loadJobProgress(Player.PlayerData.citizenid, jobKey)
        if entry.level < zone.minLevel then
            TriggerClientEvent('bu-jobs:client:notify', src, 'Нужен уровень ' .. zone.minLevel .. ', чтобы ловить здесь.', 'error')
            return
        end
    end

    local info = nil
    if job.item == 'fish' then
        local fishes = zone.fish or { { name = 'Рыба', price = 15 } }
        local fish = fishes[math.random(#fishes)]
        info = { fishType = fish.name, price = fish.price }
    end

    local added = Player.Functions.AddItem(job.item, 1, false, info)
    if not added then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Инвентарь полон.', 'error')
        return
    end

    payForAction(Player, src, jobKey)
end)

-- Продажа ресурсов на центральном рынке за наличные
RegisterNetEvent('bu-jobs:server:marketSell', function(jobKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Config.Jobs[jobKey]
    if not job or not job.item then return end
    if not checkJob(Player, src, jobKey, job) then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - Config.Market.coords) > Config.Market.radius then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Рынок далеко. Приезжай на центральный рынок у площади Легион.', 'error')
        return
    end

    local price = Config.Market.prices[job.item]
    if job.item == 'fish' then
        price = item.info and tonumber(item.info.price) or 0
    end
    if not price then return end

    local item = Player.Functions.GetItemByName(job.item)
    if not item or not item.amount or item.amount <= 0 then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Нечего продавать.', 'error')
        return
    end

    local count = item.amount
    local total = count * price

    Player.Functions.RemoveItem(job.item, count, false, item.slot)
    Player.Functions.AddMoney('cash', total, 'market-sell-' .. jobKey)

    TriggerClientEvent('bu-jobs:client:notify', src, string.format('Продано %d шт. за $%d наличными.', count, total), 'success')
end)

RegisterNetEvent('bu-jobs:server:deliver', function(jobKey, pointIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Config.Jobs[jobKey]
    if not job or not job.route then return end
    if not checkJob(Player, src, jobKey, job) then return end
    if isCooldown(src) then return end

    local point = job.route[tonumber(pointIndex)]
    if not point then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - point) > 12.0 then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Ты не у точки доставки.', 'error')
        return
    end

    payForAction(Player, src, jobKey)
end)

-- Внешние работы (такси, дальнобойщик): оплату дают qb-скрипты,
-- движок добавляет опыт и бонус за уровень сверху
RegisterNetEvent('bu-jobs:server:externalAction', function(jobKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Config.Jobs[jobKey]
    if not job then return end
    if Player.PlayerData.job.name ~= jobKey then return end
    if isCooldown(src) then return end

    local level, leveledUp = addProgress(Player.PlayerData.citizenid, jobKey, job.xp)
    local multiplier = Config.PayMultipliers[level] or 1.0
    local bonus = math.floor(job.basePay * (multiplier - 1))

    if bonus > 0 then
        Player.Functions.AddMoney('cash', bonus, 'job-' .. jobKey .. '-level-bonus')
        TriggerEvent('bu-tutorial:server:jobEarned', Player.PlayerData.citizenid, bonus)
    end

    local message = string.format('%s: опыт +%d. Уровень %d/10.', job.label, job.xp, level)
    if leveledUp then message = message .. ' Новый уровень!' end
    if bonus > 0 then message = message .. string.format(' Бонус за уровень: +$%d.', bonus) end

    TriggerClientEvent('bu-jobs:client:notify', src, message, 'success')
end)

-- Охота: олени спавнятся сервером, оплату получает ближайший охотник с лицензией
local deerList = {}
local hunterJob = Config.Jobs.hunter
local function spawnDeer()
    local angle = math.random() * math.pi * 2
    local distance = math.random(10, 100)
    local x = hunterJob.zone.x + math.cos(angle) * distance
    local y = hunterJob.zone.y + math.sin(angle) * distance
    local z = hunterJob.zone.z

    local deer = CreatePed(28, GetHashKey('a_c_deer'), x, y, z, 0.0, true, false)
    return deer
end

if hunterJob then
    CreateThread(function()
        for i = 1, 6 do
            deerList[#deerList + 1] = spawnDeer()
        end

        while true do
            Wait(1000)
            for i = 1, #deerList do
                local deer = deerList[i]
                if not DoesEntityExist(deer) or GetEntityHealth(deer) <= 0 then
                    local killer = nil
                    local killerDistance = 51.0

                    for _, target in pairs(QBCore.Functions.GetQBPlayers()) do
                        if target.PlayerData.job.name == 'hunter' and target.Functions.GetItemByName('hunting_license') then
                            local distance = #(GetEntityCoords(GetPlayerPed(target.PlayerData.source)) - hunterJob.zone)
                            if distance < killerDistance then
                                killer = target
                                killerDistance = distance
                            end
                        end
                    end

                    if killer then
                        local level, leveledUp = addProgress(killer.PlayerData.citizenid, 'hunter', hunterJob.xp)
                        local multiplier = Config.PayMultipliers[level] or 1.0
                        local pay = math.floor(hunterJob.basePay * multiplier)
                        killer.Functions.AddMoney('bank', pay, 'hunter-warden')

                        local message = string.format('Служба охраны природы: выстрел зафиксирован, зверя заберут специалисты. Оплата переведена: +$%d. Уровень %d/10.', pay, level)
                        if leveledUp then message = message .. ' Новый уровень!' end
                        TriggerClientEvent('bu-jobs:client:notify', killer.PlayerData.source, message, 'inform')
                    end

                    if DoesEntityExist(deer) then
                        DeleteEntity(deer)
                    end
                    deerList[i] = spawnDeer()
                end
            end
        end
    end)
end

-- ============================================================
-- Такси: заказы от игроков. Цена по расстоянию, на 30% дороже NPC.
-- ============================================================

local taxiOrders = {} -- id -> { id, requester, name, pickup, destIndex, price, status, driver }
local taxiNextId = 1

local function taxiPrice(pickup, destCoords)
    local distanceKm = #(pickup - destCoords) / 1000
    local price = math.ceil(distanceKm * Config.Taxi.pricePerKm * (1 + Config.Taxi.playerBonus))
    return math.max(price, 100)
end

local function notifyTaxiDrivers(message)
    for _, Player in pairs(QBCore.Functions.GetQBPlayers()) do
        if Player.PlayerData.job.name == 'taxi' and Player.PlayerData.job.onduty then
            TriggerClientEvent('bu-jobs:client:notify', Player.PlayerData.source, message, 'inform')
        end
    end
end

-- Данные для приложения «Такси» в телефоне: точки назначения и мой заказ
QBCore.Functions.CreateCallback('bu-jobs:server:getTaxiClientData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local destinations = {}
    for i = 1, #Config.Taxi.destinations do
        destinations[#destinations + 1] = { index = i, label = Config.Taxi.destinations[i].label }
    end

    local myOrder = nil
    for _, order in pairs(taxiOrders) do
        if order.requester == Player.PlayerData.citizenid and (order.status == 'open' or order.status == 'taken') then
            myOrder = {
                destination = Config.Taxi.destinations[order.destIndex].label,
                price = order.price,
                status = order.status
            }
        end
    end

    cb({ destinations = destinations, myOrder = myOrder })
end)

RegisterNetEvent('bu-jobs:server:createTaxiOrder', function(destIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local destination = Config.Taxi.destinations[tonumber(destIndex)]
    if not destination then return end

    local cid = Player.PlayerData.citizenid
    for _, order in pairs(taxiOrders) do
        if order.requester == cid and order.status == 'open' then
            TriggerClientEvent('bu-jobs:client:notify', src, 'У тебя уже есть активный заказ такси.', 'error')
            return
        end
    end

    local pickup = GetEntityCoords(GetPlayerPed(src))
    local price = taxiPrice(pickup, destination.coords)

    taxiOrders[taxiNextId] = {
        id = taxiNextId,
        requester = cid,
        name = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or ''),
        pickup = pickup,
        destIndex = tonumber(destIndex),
        price = price,
        status = 'open'
    }
    taxiNextId = taxiNextId + 1

    notifyTaxiDrivers('Новый заказ такси: ' .. destination.label .. ', $' .. price)
    TriggerClientEvent('bu-jobs:client:notify', src, string.format('Заказ принят! Такси едет за тобой. Поездка до «%s» будет стоить $%d.', destination.label, price), 'success')
end)

QBCore.Functions.CreateCallback('bu-jobs:server:getTaxiOrders', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end
    if Player.PlayerData.job.name ~= 'taxi' then return cb({}) end

    local list = {}
    for _, order in pairs(taxiOrders) do
        if order.status == 'open' then
            local destination = Config.Taxi.destinations[order.destIndex]
            list[#list + 1] = {
                id = order.id,
                name = order.name,
                price = order.price,
                destination = destination and destination.label or '',
                pickup = order.pickup
            }
        end
    end

    local mine = nil
    for _, order in pairs(taxiOrders) do
        if order.driver == Player.PlayerData.citizenid and order.status == 'taken' then
            local destination = Config.Taxi.destinations[order.destIndex]
            mine = {
                id = order.id,
                name = order.name,
                price = order.price,
                destination = destination and destination.label or '',
                pickup = order.pickup,
                drop = destination and destination.coords or order.pickup
            }
        end
    end

    cb({ orders = list, mine = mine })
end)

RegisterNetEvent('bu-jobs:server:takeTaxiOrder', function(orderId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'taxi' then return end

    local order = taxiOrders[tonumber(orderId)]
    if not order or order.status ~= 'open' then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Заказ уже занят или не существует.', 'error')
        return
    end

    local Requester = QBCore.Functions.GetPlayerByCitizenId(order.requester)
    if not Requester then
        taxiOrders[order.id] = nil
        TriggerClientEvent('bu-jobs:client:notify', src, 'Пассажир уже вышел из игры.', 'error')
        return
    end

    order.status = 'taken'
    order.driver = Player.PlayerData.citizenid

    TriggerClientEvent('bu-jobs:client:notify', src, 'Заказ принят. Езжай к пассажиру, затем — к точке назначения.', 'success')
    TriggerClientEvent('bu-jobs:client:taxiWaypoint', src, order.pickup)
    TriggerClientEvent('bu-jobs:client:notify', Requester.PlayerData.source, 'Такси приняло заказ и уже едет.', 'success')
end)

RegisterNetEvent('bu-jobs:server:finishTaxiOrder', function(orderId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local order = taxiOrders[tonumber(orderId)]
    if not order or order.status ~= 'taken' or order.driver ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Это не твой активный заказ.', 'error')
        return
    end

    local destination = Config.Taxi.destinations[order.destIndex]
    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - destination.coords) > Config.Taxi.completeRadius then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Приезжай к точке назначения.', 'error')
        return
    end

    taxiOrders[order.id] = nil

    local Requester = QBCore.Functions.GetPlayerByCitizenId(order.requester)
    if Requester then
        if Requester.PlayerData.money.bank >= order.price then
            Requester.Functions.RemoveMoney('bank', order.price, 'taxi-fare')
        else
            Requester.Functions.RemoveMoney('cash', order.price, 'taxi-fare')
        end
    end

    Player.Functions.AddMoney('cash', order.price, 'taxi-player-fare')
    TriggerEvent('bu-jobs:server:externalActionFor', src, 'taxi')

    TriggerClientEvent('bu-jobs:client:notify', src, string.format('Поездка завершена: +$%d наличными.', order.price), 'success')
    if Requester then
        TriggerClientEvent('bu-jobs:client:notify', Requester.PlayerData.source, 'Спасибо за поездку!', 'success')
    end
end)

-- Внутренний вызов движка уровней без повторного антиспам-кулдауна
RegisterNetEvent('bu-jobs:server:externalActionFor', function(jobKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Config.Jobs[jobKey]
    if not job or Player.PlayerData.job.name ~= jobKey then return end

    local level, leveledUp = addProgress(Player.PlayerData.citizenid, jobKey, job.xp)
    local multiplier = Config.PayMultipliers[level] or 1.0
    local bonus = math.floor(job.basePay * (multiplier - 1))
    if bonus > 0 then
        Player.Functions.AddMoney('cash', bonus, 'job-' .. jobKey .. '-level-bonus')
        TriggerEvent('bu-tutorial:server:jobEarned', Player.PlayerData.citizenid, bonus)
    end

    local message = string.format('%s: опыт +%d. Уровень %d/10.', job.label, job.xp, level)
    if leveledUp then message = message .. ' Новый уровень!' end
    if bonus > 0 then message = message .. string.format(' Бонус за уровень: +$%d.', bonus) end
    TriggerClientEvent('bu-jobs:client:notify', src, message, 'success')
end)

-- ============================================================
-- Дальнобой: заказы бизнесов и маршруты NPC
-- ============================================================

local truckerTaken = {} -- orderKey -> { driver, pickupDone }

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_trucker_orders` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `owner` varchar(50) NOT NULL,
            `owner_name` varchar(64) NOT NULL DEFAULT '',
            `prop_key` varchar(64) NOT NULL,
            `prop_label` varchar(64) NOT NULL DEFAULT '',
            `units` int(11) NOT NULL DEFAULT 1,
            `reward` int(11) NOT NULL DEFAULT 0,
            `pickup_x` float NOT NULL,
            `pickup_y` float NOT NULL,
            `pickup_z` float NOT NULL,
            `drop_x` float NOT NULL,
            `drop_y` float NOT NULL,
            `drop_z` float NOT NULL,
            `status` varchar(16) NOT NULL DEFAULT 'open',
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `idx_status` (`status`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

local function createTruckerOrder(ownerCid, ownerName, propKey, propLabel, units)
    local warehouse = Config.Trucker.warehouses[math.random(1, #Config.Trucker.warehouses)]
    local dropResult = MySQL.query.await('SELECT drop_x, drop_y, drop_z FROM bu_properties WHERE prop_key = ? LIMIT 1', { propKey })
    local drop = dropResult and dropResult[1] and vec3(dropResult[1].drop_x, dropResult[1].drop_y, dropResult[1].drop_z) or vec3(0.0, 0.0, 0.0)

    local reward = Config.Trucker.rewardPerUnit * units

    MySQL.insert('INSERT INTO bu_trucker_orders (owner, owner_name, prop_key, prop_label, units, reward, pickup_x, pickup_y, pickup_z, drop_x, drop_y, drop_z) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        ownerCid, ownerName, propKey, propLabel, units, reward,
        warehouse.coords.x, warehouse.coords.y, warehouse.coords.z,
        drop.x, drop.y, drop.z
    })

    return warehouse
end
exports('createTruckerOrder', createTruckerOrder)

QBCore.Functions.CreateCallback('bu-jobs:server:getTruckerOrders', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end
    if Player.PlayerData.job.name ~= 'trucker' then return cb({}) end

    local orders = {}
    local result = MySQL.query.await('SELECT id, prop_label, units, reward, pickup_x, pickup_y, pickup_z, drop_x, drop_y, drop_z FROM bu_trucker_orders WHERE status = ? ORDER BY id ASC LIMIT 20', { 'open' })
    if result then
        for i = 1, #result do
            local row = result[i]
            orders[#orders + 1] = {
                id = row.id,
                label = row.prop_label,
                units = row.units,
                reward = row.reward,
                pickup = vec3(row.pickup_x, row.pickup_y, row.pickup_z),
                drop = vec3(row.drop_x, row.drop_y, row.drop_z)
            }
        end
    end

    local mine = nil
    local myKey = nil
    for key, value in pairs(truckerTaken) do
        if value.driver == Player.PlayerData.citizenid then
            myKey = key
        end
    end
    if myKey then
        local active = truckerTaken[myKey]
        if myKey:sub(1, 6) == 'order:' then
            local id = tonumber(myKey:sub(7))
            local row = MySQL.query.await('SELECT id, prop_label, units, reward, pickup_x, pickup_y, pickup_z, drop_x, drop_y, drop_z FROM bu_trucker_orders WHERE id = ? LIMIT 1', { id })
            if row and row[1] then
                mine = {
                    key = myKey,
                    label = 'Заказ: ' .. row[1].prop_label,
                    units = row[1].units,
                    reward = row[1].reward,
                    pickup = vec3(row[1].pickup_x, row[1].pickup_y, row[1].pickup_z),
                    drop = vec3(row[1].drop_x, row[1].drop_y, row[1].drop_z),
                    pickupDone = active.pickupDone
                }
            end
        else
            local npcIndex = tonumber(myKey:match('npc:(%d+)'))
            local route = Config.Trucker.npcRoutes[npcIndex]
            if route then
                mine = {
                    key = myKey,
                    label = route.label,
                    units = 0,
                    reward = route.reward,
                    pickup = route.pickup,
                    drop = route.drop,
                    pickupDone = active.pickupDone
                }
            end
        end
    end

    cb({ orders = orders, npcRoutes = Config.Trucker.npcRoutes, mine = mine })
end)

RegisterNetEvent('bu-jobs:server:takeTruckerOrder', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'trucker' then return end

    if next(truckerTaken) then
        for k, value in pairs(truckerTaken) do
            if value.driver == Player.PlayerData.citizenid then
                TriggerClientEvent('bu-jobs:client:notify', src, 'У тебя уже есть активный рейс. Сначала заверши его.', 'error')
                return
            end
        end
    end

    local pickup
    if key:sub(1, 6) == 'order:' then
        local id = tonumber(key:sub(7))
        local row = MySQL.query.await('SELECT pickup_x, pickup_y, pickup_z FROM bu_trucker_orders WHERE id = ? AND status = ? LIMIT 1', { id, 'open' })
        if not row or not row[1] then
            TriggerClientEvent('bu-jobs:client:notify', src, 'Заказ уже занят.', 'error')
            return
        end
        MySQL.update('UPDATE bu_trucker_orders SET status = ? WHERE id = ?', { 'taken', id })
        pickup = vec3(row[1].pickup_x, row[1].pickup_y, row[1].pickup_z)
    else
        local npcIndex = tonumber(key:match('npc:(%d+)'))
        local route = Config.Trucker.npcRoutes[npcIndex]
        if not route then return end
        pickup = route.pickup
    end

    truckerTaken[key] = { driver = Player.PlayerData.citizenid, pickupDone = false }

    TriggerClientEvent('bu-jobs:client:notify', src, 'Рейс принят. Езжай на склад и забирай груз.', 'success')
    TriggerClientEvent('bu-jobs:client:truckerWaypoint', src, pickup)
end)

RegisterNetEvent('bu-jobs:server:truckerPickup', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local active = truckerTaken[key]
    if not active or active.driver ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Это не твой рейс.', 'error')
        return
    end

    local pickup
    if key:sub(1, 6) == 'order:' then
        local id = tonumber(key:sub(7))
        local row = MySQL.query.await('SELECT pickup_x, pickup_y, pickup_z FROM bu_trucker_orders WHERE id = ? LIMIT 1', { id })
        if row and row[1] then pickup = vec3(row[1].pickup_x, row[1].pickup_y, row[1].pickup_z) end
    else
        local npcIndex = tonumber(key:match('npc:(%d+)'))
        pickup = Config.Trucker.npcRoutes[npcIndex] and Config.Trucker.npcRoutes[npcIndex].pickup or nil
    end

    if not pickup or #(GetEntityCoords(GetPlayerPed(src)) - pickup) > Config.Trucker.pickupRadius then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Ты не у склада.', 'error')
        return
    end

    active.pickupDone = true

    local drop
    if key:sub(1, 6) == 'order:' then
        local id = tonumber(key:sub(7))
        local row = MySQL.query.await('SELECT drop_x, drop_y, drop_z FROM bu_trucker_orders WHERE id = ? LIMIT 1', { id })
        if row and row[1] then drop = vec3(row[1].drop_x, row[1].drop_y, row[1].drop_z) end
    else
        local npcIndex = tonumber(key:match('npc:(%d+)'))
        drop = Config.Trucker.npcRoutes[npcIndex] and Config.Trucker.npcRoutes[npcIndex].drop or nil
    end

    TriggerClientEvent('bu-jobs:client:notify', src, 'Груз загружен. Вези его к бизнесу.', 'success')
    if drop then TriggerClientEvent('bu-jobs:client:truckerWaypoint', src, drop) end
end)

RegisterNetEvent('bu-jobs:server:finishTruckerOrder', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local active = truckerTaken[key]
    if not active or active.driver ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Это не твой рейс.', 'error')
        return
    end
    if not active.pickupDone then
        TriggerClientEvent('bu-jobs:client:notify', src, 'Сначала забери груз со склада.', 'error')
        return
    end

    local drop
    local reward
    local units = 0

    if key:sub(1, 6) == 'order:' then
        local id = tonumber(key:sub(7))
        local row = MySQL.query.await('SELECT drop_x, drop_y, drop_z, reward, units, prop_key FROM bu_trucker_orders WHERE id = ? LIMIT 1', { id })
        if not row or not row[1] then
            TriggerClientEvent('bu-jobs:client:notify', src, 'Заказ не найден.', 'error')
            return
        end
        drop = vec3(row[1].drop_x, row[1].drop_y, row[1].drop_z)
        reward = row[1].reward
        units = row[1].units

        if #(GetEntityCoords(GetPlayerPed(src)) - drop) > Config.Trucker.dropRadius then
            TriggerClientEvent('bu-jobs:client:notify', src, 'Ты не у бизнеса.', 'error')
            return
        end

        MySQL.update('UPDATE bu_trucker_orders SET status = ? WHERE id = ?', { 'done', id })
        MySQL.update('UPDATE bu_properties SET supplies = COALESCE(supplies, 0) + ? WHERE prop_key = ?', { units, row[1].prop_key })
    else
        local npcIndex = tonumber(key:match('npc:(%d+)'))
        local route = Config.Trucker.npcRoutes[npcIndex]
        if not route then return end
        drop = route.drop
        reward = route.reward

        if #(GetEntityCoords(GetPlayerPed(src)) - drop) > Config.Trucker.dropRadius then
            TriggerClientEvent('bu-jobs:client:notify', src, 'Ты не у точки разгрузки.', 'error')
            return
        end
    end

    truckerTaken[key] = nil
    Player.Functions.AddMoney('cash', reward, 'trucker-order')
    TriggerEvent('bu-jobs:server:externalActionFor', src, 'trucker')

    TriggerClientEvent('bu-jobs:client:notify', src, string.format('Груз доставлен: +$%d наличными.', reward), 'success')
end)
