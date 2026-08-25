local QBCore = exports['qb-core']:GetCoreObject()

-- Активные аренды: citizenid -> { entity, plate, model, label, expiresAt }
local activeRentals = {}

local standPos = vec3(Config.Stand.coords.x, Config.Stand.coords.y, Config.Stand.coords.z)

local function finishRental(cid)
    local rental = activeRentals[cid]
    if not rental then return false end

    if DoesEntityExist(rental.entity) then
        DeleteEntity(rental.entity)
    end
    activeRentals[cid] = nil
    return true
end
exports('finishRental', finishRental)

-- Внешняя аренда (маркетплейс): машина появляется рядом с игроком
local function addExternalRental(cid, model, label, plate, hours)
    local target = QBCore.Functions.GetPlayerByCitizenId(cid)
    if not target then return false end

    local ped = GetPlayerPed(target.PlayerData.source)
    local pos = GetEntityCoords(ped)
    local entity = CreateVehicle(joaat(model), pos.x + 3.0, pos.y, pos.z, 0.0, true, false)
    while not DoesEntityExist(entity) do Wait(0) end

    SetVehicleNumberPlateText(entity, plate)
    SetVehicleDirtLevel(entity, 0.0)

    activeRentals[cid] = {
        entity = entity,
        plate = plate,
        model = model,
        label = label,
        expiresAt = os.time() + hours * 3600
    }
    exports['qb-vehiclekeys']:GiveKeys(plate, cid)
    return true
end
exports('addExternalRental', addExternalRental)

-- Данные активной аренды для приложения «Аренда» в телефоне
exports('getActiveRental', function(cid)
    local rental = activeRentals[cid]
    if not rental then return nil end
    return { plate = rental.plate, label = rental.label, expiresAt = rental.expiresAt }
end)

QBCore.Functions.CreateCallback('bu-rental:server:getActive', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    cb(exports['bu-rental']:getActiveRental(Player.PlayerData.citizenid))
end)

-- Истечение срока: машина снимается, игрок получает уведомление
CreateThread(function()
    while true do
        Wait(30000)
        local now = os.time()
        for cid, rental in pairs(activeRentals) do
            if now >= rental.expiresAt then
                if DoesEntityExist(rental.entity) then DeleteEntity(rental.entity) end
                activeRentals[cid] = nil

                local target = QBCore.Functions.GetPlayerByCitizenId(cid)
                if target then
                    TriggerClientEvent('bu-rental:client:notify', target.PlayerData.source, 'Время аренды истекло, транспорт возвращён в прокат.', 'error')
                end
            end
        end
    end
end)

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_rental_log` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `vehicle` varchar(32) NOT NULL,
            `price` int(11) NOT NULL DEFAULT 0,
            `hours` int(11) NOT NULL DEFAULT 1,
            `rented_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `idx_citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

        MySQL.query('ALTER TABLE `bu_rental_log` ADD COLUMN IF NOT EXISTS `hours` int(11) NOT NULL DEFAULT 1')
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(Player)
    finishRental(Player.PlayerData.citizenid)
end)

QBCore.Functions.CreateCallback('bu-rental:server:getVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local hasLicense = Player.Functions.GetItemByName('driver_license') ~= nil
    local list = {}
    for i = 1, #Config.Vehicles do
        local v = Config.Vehicles[i]
        list[#list + 1] = {
            id = i,
            model = v.model,
            label = v.label,
            price = v.price,
            available = not v.requiresLicense or hasLicense
        }
    end

    cb({
        vehicles = list,
        maxHours = Config.MaxRentHours,
        active = activeRentals[Player.PlayerData.citizenid] ~= nil
    })
end)

RegisterNetEvent('bu-rental:server:rent', function(vehicleId, hours, payment)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if activeRentals[cid] then
        TriggerClientEvent('bu-rental:client:notify', src, 'Сначала верни текущий транспорт у стойки.', 'error')
        return
    end

    local vehicleData = Config.Vehicles[tonumber(vehicleId)]
    if not vehicleData then return end

    hours = tonumber(hours)
    if not hours or hours < 1 or hours > Config.MaxRentHours or math.floor(hours) ~= hours then
        TriggerClientEvent('bu-rental:client:notify', src, 'Срок аренды — от 1 до ' .. Config.MaxRentHours .. ' часов.', 'error')
        return
    end

    if vehicleData.requiresLicense and not Player.Functions.GetItemByName('driver_license') then
        TriggerClientEvent('bu-rental:client:notify', src, 'Для этой машины нужны водительские права категории B.', 'error')
        return
    end

    local totalPrice = vehicleData.price * hours
    local moneyType = payment == 'cash' and 'cash' or 'bank'
    local balance = Player.PlayerData.money[moneyType]
    if not balance or balance < totalPrice then
        TriggerClientEvent('bu-rental:client:notify', src, 'Недостаточно средств.', 'error')
        return
    end

    Player.Functions.RemoveMoney(moneyType, totalPrice, 'rental-' .. vehicleData.model)

    local spawn = Config.Stand.spawn
    local plate = 'RENT' .. math.random(100, 999)
    local entity = CreateVehicle(joaat(vehicleData.model), spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    while not DoesEntityExist(entity) do Wait(0) end

    -- Ставим машину на землю (верхний ярус у стойки)
    local found, groundZ = GetGroundZFor_3dCoord(spawn.x, spawn.y, spawn.z + 40.0, false)
    if found then
        SetEntityCoords(entity, spawn.x, spawn.y, groundZ)
    end
    PlaceObjectOnGroundProperly(entity)

    SetVehicleNumberPlateText(entity, plate)
    SetVehicleDirtLevel(entity, 0.0)
    SetVehicleEngineOn(entity, false, false)

    activeRentals[cid] = {
        entity = entity,
        plate = plate,
        model = vehicleData.model,
        label = vehicleData.label,
        expiresAt = os.time() + hours * 3600
    }
    exports['qb-vehiclekeys']:GiveKeys(plate, cid)

    MySQL.insert('INSERT INTO bu_rental_log (citizenid, vehicle, price, hours) VALUES (?, ?, ?, ?)', {
        cid, vehicleData.model, totalPrice, hours
    })

    TriggerClientEvent('bu-rental:client:notify', src, string.format('%s выдан на %d ч. Госномер: %s. Вернуть можно у Steve Carter.', vehicleData.label, hours, plate), 'success')
end)

RegisterNetEvent('bu-rental:server:returnVehicle', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local distance = #(GetEntityCoords(ped) - standPos)
    if distance > Config.Stand.returnDistance then
        TriggerClientEvent('bu-rental:client:notify', src, 'Подойди к стойке Steve Carter, чтобы вернуть транспорт.', 'error')
        return
    end

    if finishRental(Player.PlayerData.citizenid) then
        TriggerClientEvent('bu-rental:client:notify', src, 'Транспорт возвращён. Приезжай ещё!', 'success')
    else
        TriggerClientEvent('bu-rental:client:notify', src, 'У тебя нет активной аренды.', 'error')
    end
end)
