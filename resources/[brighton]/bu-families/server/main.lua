local QBCore = exports['qb-core']:GetCoreObject()

-- Кэш: familyId -> { id, name, type, leader, money, members = { [citizenid] = rank } }
local familiesCache = {}
local familyOfPlayer = {}
local invites = {} -- targetCitizenid -> { familyId, type }
local activeContracts = {} -- familyId -> { contractIndex, citizenid, pickupDone }
local activeFamilyVehicles = {} -- vehicleId -> { entity, plate }
local activeOwnVehicles = {} -- citizenid -> { [plate] = { entity, garage } }

-- Территории банд живут в bu-gangs, здесь только семьи игроков

local function logAction(familyId, citizenid, action, detail)
    MySQL.insert('INSERT INTO bu_family_logs (family_id, citizenid, action, detail) VALUES (?, ?, ?, ?)', {
        familyId, citizenid, action, detail or ''
    })
end

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_families` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(32) NOT NULL,
            `type` varchar(16) NOT NULL DEFAULT 'family',
            `leader` varchar(50) NOT NULL,
            `money` bigint(20) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            UNIQUE KEY `uq_name` (`name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        MySQL.query('ALTER TABLE `bu_families` ADD COLUMN IF NOT EXISTS `type` varchar(16) NOT NULL DEFAULT \'family\'')

        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_family_members` (
            `citizenid` varchar(50) NOT NULL,
            `family_id` int(11) NOT NULL,
            `rank` int(11) NOT NULL DEFAULT 1,
            `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`citizenid`),
            KEY `idx_family` (`family_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_family_logs` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `family_id` int(11) NOT NULL,
            `citizenid` varchar(50) NOT NULL DEFAULT '',
            `action` varchar(64) NOT NULL,
            `detail` varchar(255) NOT NULL DEFAULT '',
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `idx_family` (`family_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_family_vehicles` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `family_id` int(11) NOT NULL,
            `model` varchar(32) NOT NULL,
            `label` varchar(64) NOT NULL DEFAULT '',
            `plate` varchar(16) NOT NULL,
            `in_use` tinyint(1) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `idx_family` (`family_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        MySQL.query("ALTER TABLE `bu_families` ADD COLUMN IF NOT EXISTS `office_house` varchar(50) NOT NULL DEFAULT ''")
    end)
end)

local function getFamilyConfig(family)
    return Config.Family
end

local function loadFamily(familyId)
    if familiesCache[familyId] then return familiesCache[familyId] end

    local familyResult = MySQL.query.await('SELECT id, name, type, leader, money, office_house FROM bu_families WHERE id = ? LIMIT 1', { familyId })
    if not familyResult or not familyResult[1] then return nil end

    local family = {
        id = familyResult[1].id,
        name = familyResult[1].name,
        type = familyResult[1].type or 'family',
        leader = familyResult[1].leader,
        money = familyResult[1].money,
        officeHouse = familyResult[1].office_house or '',
        members = {}
    }

    local membersResult = MySQL.query.await('SELECT citizenid, rank FROM bu_family_members WHERE family_id = ?', { familyId })
    if membersResult then
        for i = 1, #membersResult do
            family.members[membersResult[i].citizenid] = membersResult[i].rank
            familyOfPlayer[membersResult[i].citizenid] = familyId
        end
    end

    familiesCache[familyId] = family
    return family
end

local function getPlayerFamily(cid)
    local familyId = familyOfPlayer[cid]
    if not familyId then
        local result = MySQL.query.await('SELECT family_id, rank FROM bu_family_members WHERE citizenid = ? LIMIT 1', { cid })
        if result and result[1] then
            familyId = result[1].family_id
            familyOfPlayer[cid] = familyId
            local family = loadFamily(familyId)
            if family then family.members[cid] = result[1].rank end
        end
    end
    if not familyId then return nil end
    return loadFamily(familyId)
end

local function memberCount(family)
    local count = 0
    for _ in pairs(family.members) do count = count + 1 end
    return count
end

local function notifyTarget(cid, message, notifyType)
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    if Player then
        TriggerClientEvent('bu-families:client:notify', Player.PlayerData.source, message, notifyType or 'primary')
    end
end

local function playerName(cid)
    local result = MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ? LIMIT 1', { cid })
    if result and result[1] and result[1].charinfo then
        local charinfo = json.decode(result[1].charinfo)
        if charinfo then
            return (charinfo.firstname or '') .. ' ' .. (charinfo.lastname or '')
        end
    end
    return cid
end

-- Создание семьи из планшета (фракции на сервере пресетные)
RegisterNetEvent('bu-families:server:create', function(name, familyType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    familyType = 'family'
    local settings = Config.Family

    local cid = Player.PlayerData.citizenid
    if getPlayerFamily(cid) then
        TriggerClientEvent('bu-families:client:notify', src, 'Ты уже состоишь в организации.', 'error')
        return
    end

    name = name and tostring(name):gsub('%s+', ' '):trim() or ''
    if #name < 3 or #name > Config.MaxNameLength then
        TriggerClientEvent('bu-families:client:notify', src, string.format('Название должно быть от 3 до %d символов.', Config.MaxNameLength), 'error')
        return
    end

    local exists = MySQL.query.await('SELECT 1 FROM bu_families WHERE name = ? LIMIT 1', { name })
    if exists and exists[1] then
        TriggerClientEvent('bu-families:client:notify', src, 'Такое название уже занято.', 'error')
        return
    end

    local balance = Player.PlayerData.money.bank
    if not balance or balance < settings.creationPrice then
        TriggerClientEvent('bu-families:client:notify', src, string.format('Нужно $%d на банковском счёте.', settings.creationPrice), 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', settings.creationPrice, familyType .. '-create')

    local familyId = MySQL.insert.await('INSERT INTO bu_families (name, type, leader) VALUES (?, ?, ?)', { name, familyType, cid })
    MySQL.insert('INSERT INTO bu_family_members (citizenid, family_id, rank) VALUES (?, ?, ?)', { cid, familyId, settings.leaderRank })

    familiesCache[familyId] = {
        id = familyId,
        name = name,
        type = familyType,
        leader = cid,
        money = 0,
        members = { [cid] = settings.leaderRank }
    }
    familyOfPlayer[cid] = familyId

    local kind = 'Семья'
    logAction(familyId, cid, 'create', string.format('Создание: %s «%s»', kind, name))
    TriggerClientEvent('bu-families:client:notify', src, string.format('%s «%s» создана! Ты — её лидер.', kind, name), 'success')
end)

-- Офис семьи: лидер назначает свой дом офисом
RegisterNetEvent('bu-families:server:setOffice', function(house)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local family = getPlayerFamily(cid)
    if not family then return end

    local settings = getFamilyConfig(family)
    if family.members[cid] < settings.leaderRank then
        TriggerClientEvent('bu-families:client:notify', src, 'Только лидер назначает офис.', 'error')
        return
    end

    local owned = MySQL.query.await('SELECT 1 FROM player_houses WHERE citizenid = ? AND house = ? LIMIT 1', { cid, house })
    if not owned or not owned[1] then
        TriggerClientEvent('bu-families:client:notify', src, 'Этот дом тебе не принадлежит.', 'error')
        return
    end

    MySQL.update('UPDATE bu_families SET office_house = ? WHERE id = ?', { house, family.id })
    family.officeHouse = house
    logAction(family.id, cid, 'office', 'Назначен офис: ' .. house)
    TriggerClientEvent('bu-families:client:notify', src, 'Офис организации назначен.', 'success')
end)

RegisterNetEvent('bu-families:server:invite', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then
        TriggerClientEvent('bu-families:client:notify', src, 'У тебя нет организации.', 'error')
        return
    end
    local settings = getFamilyConfig(family)
    if family.members[Player.PlayerData.citizenid] < settings.leaderRank then
        TriggerClientEvent('bu-families:client:notify', src, 'Приглашать может только лидер.', 'error')
        return
    end

    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Target then
        TriggerClientEvent('bu-families:client:notify', src, 'Игрок не найден.', 'error')
        return
    end
    if getPlayerFamily(Target.PlayerData.citizenid) then
        TriggerClientEvent('bu-families:client:notify', src, 'Игрок уже состоит в организации.', 'error')
        return
    end

    invites[Target.PlayerData.citizenid] = family.id
    TriggerClientEvent('bu-families:client:notify', src, 'Приглашение отправлено.', 'success')
    TriggerClientEvent('bu-families:client:notify', targetId, string.format('Тебя приглашают в «%s». Введи /faccept, чтобы принять.', family.name), 'inform')
end)

RegisterNetEvent('bu-families:server:accept', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local familyId = invites[cid]
    if not familyId then
        TriggerClientEvent('bu-families:client:notify', src, 'У тебя нет активных приглашений.', 'error')
        return
    end
    invites[cid] = nil

    local family = loadFamily(familyId)
    if not family then return end

    local settings = getFamilyConfig(family)
    if memberCount(family) >= settings.maxMembers then
        TriggerClientEvent('bu-families:client:notify', src, 'Организация уже полная.', 'error')
        return
    end

    MySQL.insert('INSERT INTO bu_family_members (citizenid, family_id, rank) VALUES (?, ?, ?)', { cid, familyId, 1 })
    family.members[cid] = 1
    familyOfPlayer[cid] = familyId

    logAction(familyId, cid, 'join', playerName(cid))
    TriggerClientEvent('bu-families:client:notify', src, string.format('Ты вступил в «%s».', family.name), 'success')
end)

RegisterNetEvent('bu-families:server:deposit', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then
        TriggerClientEvent('bu-families:client:notify', src, 'У тебя нет организации.', 'error')
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 or math.floor(amount) ~= amount then
        TriggerClientEvent('bu-families:client:notify', src, 'Укажи корректную сумму.', 'error')
        return
    end

    local cash = Player.PlayerData.money.cash
    if not cash or cash < amount then
        TriggerClientEvent('bu-families:client:notify', src, 'Недостаточно наличных.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', amount, 'family-deposit')
    family.money = family.money + amount
    MySQL.update('UPDATE bu_families SET money = ? WHERE id = ?', { family.money, family.id })

    logAction(family.id, Player.PlayerData.citizenid, 'deposit', string.format('Внёс в казну $%d', amount))
    TriggerClientEvent('bu-families:client:notify', src, string.format('В казну внесено $%d. Баланс: $%d.', amount, family.money), 'success')
end)

RegisterNetEvent('bu-families:server:withdraw', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then
        TriggerClientEvent('bu-families:client:notify', src, 'У тебя нет организации.', 'error')
        return
    end
    local settings = getFamilyConfig(family)
    if family.members[Player.PlayerData.citizenid] < settings.leaderRank then
        TriggerClientEvent('bu-families:client:notify', src, 'Снимать может только лидер.', 'error')
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 or math.floor(amount) ~= amount then
        TriggerClientEvent('bu-families:client:notify', src, 'Укажи корректную сумму.', 'error')
        return
    end
    if family.money < amount then
        TriggerClientEvent('bu-families:client:notify', src, 'В казне недостаточно средств.', 'error')
        return
    end

    family.money = family.money - amount
    MySQL.update('UPDATE bu_families SET money = ? WHERE id = ?', { family.money, family.id })
    Player.Functions.AddMoney('cash', amount, 'family-withdraw')

    logAction(family.id, Player.PlayerData.citizenid, 'withdraw', string.format('Снял из казны $%d', amount))
    TriggerClientEvent('bu-families:client:notify', src, string.format('Снято $%d. Баланс: $%d.', amount, family.money), 'success')
end)

-- Ранг участника: лидер повышает/понижает
RegisterNetEvent('bu-families:server:setRank', function(targetCid, rank)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local family = getPlayerFamily(cid)
    if not family then return end

    local settings = getFamilyConfig(family)
    if family.members[cid] < settings.leaderRank then
        TriggerClientEvent('bu-families:client:notify', src, 'Ранги меняет только лидер.', 'error')
        return
    end

    rank = tonumber(rank)
    if not rank or rank < 1 or rank >= settings.leaderRank or not family.members[targetCid] or targetCid == cid then
        TriggerClientEvent('bu-families:client:notify', src, 'Некорректный ранг или участник.', 'error')
        return
    end

    family.members[targetCid] = rank
    MySQL.update('UPDATE bu_family_members SET rank = ? WHERE citizenid = ? AND family_id = ?', { rank, targetCid, family.id })

    logAction(family.id, cid, 'rank', string.format('%s — ранг %d', playerName(targetCid), rank))
    notifyTarget(targetCid, string.format('Твой ранг в «%s» изменён на %d.', family.name, rank), 'inform')
    TriggerClientEvent('bu-families:client:notify', src, 'Ранг обновлён.', 'success')
end)

-- Исключение участника
RegisterNetEvent('bu-families:server:kick', function(targetCid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local family = getPlayerFamily(cid)
    if not family then return end

    local settings = getFamilyConfig(family)
    if family.members[cid] < settings.leaderRank then
        TriggerClientEvent('bu-families:client:notify', src, 'Исключать может только лидер.', 'error')
        return
    end
    if not family.members[targetCid] or targetCid == cid then
        TriggerClientEvent('bu-families:client:notify', src, 'Участник не найден.', 'error')
        return
    end

    family.members[targetCid] = nil
    familyOfPlayer[targetCid] = nil
    MySQL.query('DELETE FROM bu_family_members WHERE citizenid = ? AND family_id = ?', { targetCid, family.id })

    logAction(family.id, cid, 'kick', playerName(targetCid))
    notifyTarget(targetCid, string.format('Тебя исключили из «%s».', family.name), 'error')
    TriggerClientEvent('bu-families:client:notify', src, 'Участник исключён.', 'success')
end)

-- Контракты: одна активная доставка на организацию, награда — в казну
RegisterNetEvent('bu-families:server:takeContract', function(contractIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then
        TriggerClientEvent('bu-families:client:notify', src, 'У тебя нет организации.', 'error')
        return
    end
    if activeContracts[family.id] then
        TriggerClientEvent('bu-families:client:notify', src, 'Контракт уже взят. Сначала завершите его.', 'error')
        return
    end

    local contract = Config.Contracts[tonumber(contractIndex)]
    if not contract then return end

    activeContracts[family.id] = {
        contractIndex = tonumber(contractIndex),
        citizenid = Player.PlayerData.citizenid,
        pickupDone = false
    }

    logAction(family.id, Player.PlayerData.citizenid, 'contract', string.format('Взял контракт: %s', contract.label))
    TriggerClientEvent('bu-families:client:notify', src, string.format('Контракт взят: %s. Забери груз и доставь его.', contract.label), 'success')
    TriggerClientEvent('bu-families:client:contractWaypoint', src, contract.pickup)
end)

RegisterNetEvent('bu-families:server:contractPickup', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then return end

    local active = activeContracts[family.id]
    if not active or active.citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-families:client:notify', src, 'Это не твой контракт.', 'error')
        return
    end

    local contract = Config.Contracts[active.contractIndex]
    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - contract.pickup) > Config.ContractPickupRadius then
        TriggerClientEvent('bu-families:client:notify', src, 'Ты не у точки забора груза.', 'error')
        return
    end

    active.pickupDone = true
    TriggerClientEvent('bu-families:client:notify', src, 'Груз у тебя. Вези его к точке разгрузки.', 'success')
    TriggerClientEvent('bu-families:client:contractWaypoint', src, contract.drop)
end)

RegisterNetEvent('bu-families:server:contractDeliver', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then return end

    local active = activeContracts[family.id]
    if not active or active.citizenid ~= Player.PlayerData.citizenid or not active.pickupDone then
        TriggerClientEvent('bu-families:client:notify', src, 'Сначала забери груз по контракту.', 'error')
        return
    end

    local contract = Config.Contracts[active.contractIndex]
    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - contract.drop) > Config.ContractDropRadius then
        TriggerClientEvent('bu-families:client:notify', src, 'Ты не у точки разгрузки.', 'error')
        return
    end

    activeContracts[family.id] = nil
    family.money = family.money + contract.reward
    MySQL.update('UPDATE bu_families SET money = ? WHERE id = ?', { family.money, family.id })

    logAction(family.id, Player.PlayerData.citizenid, 'contract', string.format('Выполнен: %s (+$%d в казну)', contract.label, contract.reward))
    TriggerClientEvent('bu-families:client:notify', src, string.format('Контракт выполнен! В казну зачислено $%d.', contract.reward), 'success')
end)

-- Гараж организации: лидер покупает машины с казны
RegisterNetEvent('bu-families:server:buyVehicle', function(vehicleIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local family = getPlayerFamily(cid)
    if not family then return end

    local settings = getFamilyConfig(family)
    if family.members[cid] < settings.leaderRank then
        TriggerClientEvent('bu-families:client:notify', src, 'Машины покупает только лидер.', 'error')
        return
    end

    local vehicle = Config.GarageVehicles[tonumber(vehicleIndex)]
    if not vehicle then return end
    if family.money < vehicle.price then
        TriggerClientEvent('bu-families:client:notify', src, 'В казне недостаточно средств.', 'error')
        return
    end

    family.money = family.money - vehicle.price
    MySQL.update('UPDATE bu_families SET money = ? WHERE id = ?', { family.money, family.id })

    local plate = 'FAM' .. math.random(100, 999)
    MySQL.insert('INSERT INTO bu_family_vehicles (family_id, model, label, plate) VALUES (?, ?, ?, ?)', {
        family.id, vehicle.model, vehicle.label, plate
    })

    logAction(family.id, cid, 'vehicle', string.format('Куплен %s за $%d из казны', vehicle.label, vehicle.price))
    TriggerClientEvent('bu-families:client:notify', src, string.format('%s куплен для организации. Госномер: %s.', vehicle.label, plate), 'success')
end)

local function nearestParking(position)
    local best = nil
    local bestDistance = Config.ParkingDistance
    for i = 1, #Config.ParkingPoints do
        local point = Config.ParkingPoints[i]
        local distance = #(position - vec3(point.coords.x, point.coords.y, point.coords.z))
        if distance <= bestDistance then
            best = point
            bestDistance = distance
        end
    end
    return best
end

-- Вызов машины организации через телефон
RegisterNetEvent('bu-families:server:takeVehicle', function(vehicleId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then
        TriggerClientEvent('bu-families:client:notify', src, 'У тебя нет организации.', 'error')
        return
    end

    local position = GetEntityCoords(GetPlayerPed(src))
    local point = nearestParking(position)
    if not point then
        TriggerClientEvent('bu-families:client:notify', src, 'Подойди к одной из парковок города (точки на карте в приложении «Парковка»).', 'error')
        return
    end

    local result = MySQL.query.await('SELECT id, model, label, plate, in_use FROM bu_family_vehicles WHERE id = ? AND family_id = ? LIMIT 1', { tonumber(vehicleId), family.id })
    if not result or not result[1] then
        TriggerClientEvent('bu-families:client:notify', src, 'Машина не найдена.', 'error')
        return
    end
    if result[1].in_use == 1 then
        TriggerClientEvent('bu-families:client:notify', src, 'Машина уже у кого-то из участников.', 'error')
        return
    end

    local entity = CreateVehicle(joaat(result[1].model), point.coords.x, point.coords.y, point.coords.z, point.coords.w, true, false)
    while not DoesEntityExist(entity) do Wait(0) end
    SetVehicleNumberPlateText(entity, result[1].plate)

    activeFamilyVehicles[result[1].id] = { entity = entity, plate = result[1].plate }
    MySQL.update('UPDATE bu_family_vehicles SET in_use = 1 WHERE id = ?', { result[1].id })
    exports['qb-vehiclekeys']:GiveKeys(result[1].plate, Player.PlayerData.citizenid)

    logAction(family.id, Player.PlayerData.citizenid, 'vehicle', string.format('Взял %s (%s)', result[1].label, result[1].plate))
    TriggerClientEvent('bu-families:client:notify', src, string.format('%s подан на парковку. Госномер: %s.', result[1].label, result[1].plate), 'success')
end)

RegisterNetEvent('bu-families:server:returnVehicle', function(vehicleId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    local point = nearestParking(position)
    if not point then
        TriggerClientEvent('bu-families:client:notify', src, 'Вернуть машину можно только на парковке города.', 'error')
        return
    end

    local active = activeFamilyVehicles[tonumber(vehicleId)]
    if not active then
        TriggerClientEvent('bu-families:client:notify', src, 'Машина не выдана.', 'error')
        return
    end

    if DoesEntityExist(active.entity) then DeleteEntity(active.entity) end
    activeFamilyVehicles[tonumber(vehicleId)] = nil
    MySQL.update('UPDATE bu_family_vehicles SET in_use = 0 WHERE id = ?', { tonumber(vehicleId) })

    logAction(family.id, Player.PlayerData.citizenid, 'vehicle', string.format('Вернул %s', active.plate))
    TriggerClientEvent('bu-families:client:notify', src, 'Машина возвращена в гараж организации.', 'success')
end)

-- Личная машина: вызов на парковку и возврат
RegisterNetEvent('bu-families:server:callOwnVehicle', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    local point = nearestParking(position)
    if not point then
        TriggerClientEvent('bu-families:client:notify', src, 'Подойди к одной из парковок города.', 'error')
        return
    end

    local cid = Player.PlayerData.citizenid
    if activeOwnVehicles[cid] and activeOwnVehicles[cid][plate] then
        TriggerClientEvent('bu-families:client:notify', src, 'Эта машина уже у тебя.', 'error')
        return
    end

    local result = MySQL.query.await('SELECT vehicle, plate, garage FROM player_vehicles WHERE citizenid = ? AND plate = ? AND state = 1 LIMIT 1', { cid, plate })
    if not result or not result[1] then
        TriggerClientEvent('bu-families:client:notify', src, 'Машина не найдена или уже выгнана из гаража.', 'error')
        return
    end

    local entity = CreateVehicle(joaat(result[1].vehicle), point.coords.x, point.coords.y, point.coords.z, point.coords.w, true, false)
    while not DoesEntityExist(entity) do Wait(0) end
    SetVehicleNumberPlateText(entity, plate)

    activeOwnVehicles[cid] = activeOwnVehicles[cid] or {}
    activeOwnVehicles[cid][plate] = { entity = entity, garage = result[1].garage or 'c' }
    MySQL.update('UPDATE player_vehicles SET state = 0 WHERE citizenid = ? AND plate = ?', { cid, plate })
    exports['qb-vehiclekeys']:GiveKeys(plate, cid)

    TriggerClientEvent('bu-families:client:notify', src, 'Машина подана на парковку. Вернуть её можно через приложение «Парковка».', 'success')
end)

RegisterNetEvent('bu-families:server:parkOwnVehicle', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    local point = nearestParking(position)
    if not point then
        TriggerClientEvent('bu-families:client:notify', src, 'Припарковать можно только на парковке города.', 'error')
        return
    end

    local cid = Player.PlayerData.citizenid
    local active = activeOwnVehicles[cid] and activeOwnVehicles[cid][plate]
    if not active then
        TriggerClientEvent('bu-families:client:notify', src, 'Машина не вызывалась через приложение.', 'error')
        return
    end

    if DoesEntityExist(active.entity) then DeleteEntity(active.entity) end
    activeOwnVehicles[cid][plate] = nil
    MySQL.update('UPDATE player_vehicles SET state = 1, garage = ? WHERE citizenid = ? AND plate = ?', { active.garage, cid, plate })

    TriggerClientEvent('bu-families:client:notify', src, 'Машина припаркована.', 'success')
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local own = activeOwnVehicles[cid]
    if own then
        for plate, active in pairs(own) do
            if DoesEntityExist(active.entity) then DeleteEntity(active.entity) end
            MySQL.update('UPDATE player_vehicles SET state = 1, garage = ? WHERE citizenid = ? AND plate = ?', { active.garage, cid, plate })
        end
        activeOwnVehicles[cid] = nil
    end
end)

-- Данные для планшета: карточка организации, участники, логи, гараж, контракты
QBCore.Functions.CreateCallback('bu-families:server:getInfo', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    if not family then return cb({ none = true }) end

    local settings = getFamilyConfig(family)
    local members = {}
    for memberCid, rank in pairs(family.members) do
        members[#members + 1] = { citizenid = memberCid, name = playerName(memberCid), rank = rank }
    end
    table.sort(members, function(a, b) return a.rank > b.rank end)

    local isLeader = family.members[Player.PlayerData.citizenid] >= settings.leaderRank

    -- Логи казны и транспорта доступны только лидеру
    local logs = {}
    if isLeader then
        local logResult = MySQL.query.await('SELECT citizenid, action, detail, created_at FROM bu_family_logs WHERE family_id = ? ORDER BY id DESC LIMIT ?', { family.id, Config.LogKeep })
        if logResult then
            for i = 1, #logResult do
                logs[#logs + 1] = {
                    name = playerName(logResult[i].citizenid),
                    action = logResult[i].action,
                    detail = logResult[i].detail,
                    date = logResult[i].created_at
                }
            end
        end
    end

    local garage = {}
    local garageResult = MySQL.query.await('SELECT id, model, label, plate, in_use FROM bu_family_vehicles WHERE family_id = ?', { family.id })
    if garageResult then
        for i = 1, #garageResult do
            garage[#garage + 1] = {
                id = garageResult[i].id,
                label = garageResult[i].label,
                plate = garageResult[i].plate,
                inUse = garageResult[i].in_use == 1
            }
        end
    end

    local active = activeContracts[family.id]
    local contract = active and Config.Contracts[active.contractIndex]

    -- Офис семьи
    local office = family.officeHouse or ''

    cb({
        none = false,
        name = family.name,
        type = family.type,
        rank = family.members[Player.PlayerData.citizenid] or 1,
        isLeader = family.members[Player.PlayerData.citizenid] >= settings.leaderRank,
        leaderRank = settings.leaderRank,
        money = family.money,
        memberCount = #members,
        members = members,
        logs = logs,
        garage = garage,
        garageCatalog = Config.GarageVehicles,
        contracts = Config.Contracts,
        office = office,
        activeContract = contract and {
            index = active.contractIndex,
            label = contract.label,
            reward = contract.reward,
            pickupDone = active.pickupDone,
            taker = playerName(active.citizenid)
        } or nil
    })
end)

-- Данные для телефона: парковки, свои машины, машины организации
QBCore.Functions.CreateCallback('bu-families:server:getParkingData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local points = {}
    for i = 1, #Config.ParkingPoints do
        local point = Config.ParkingPoints[i]
        points[#points + 1] = { name = point.name, coords = point.coords }
    end

    local own = {}
    local result = MySQL.query.await('SELECT vehicle, plate, garage FROM player_vehicles WHERE citizenid = ? AND state = 1 LIMIT 20', { Player.PlayerData.citizenid })
    if result then
        for i = 1, #result do
            local catalog = QBCore.Shared.Vehicles and QBCore.Shared.Vehicles[result[i].vehicle]
            local label = result[i].vehicle
            if catalog then label = (catalog.brand or '') .. ' ' .. (catalog.name or result[i].vehicle) end
            own[#own + 1] = { plate = result[i].plate, label = label }
        end
    end

    local family = getPlayerFamily(Player.PlayerData.citizenid)
    local familyVehicles = {}
    if family then
        local famResult = MySQL.query.await('SELECT id, label, plate, in_use FROM bu_family_vehicles WHERE family_id = ?', { family.id })
        if famResult then
            for i = 1, #famResult do
                familyVehicles[#familyVehicles + 1] = {
                    id = famResult[i].id,
                    label = famResult[i].label .. ' (' .. family.name .. ')',
                    plate = famResult[i].plate,
                    inUse = famResult[i].in_use == 1
                }
            end
        end
    end

    cb({ points = points, own = own, family = familyVehicles })
end)

