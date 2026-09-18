local QBCore = exports['qb-core']:GetCoreObject()

local activeRobbery = {}      -- cid -> true
local activeCarTheft = {}     -- cid -> true
local carStolen = {}          -- cid -> true
local contrabandJob = {}      -- cid -> spotIndex
local hookerState = {}        -- cid -> 1 (забрать) | 2 (везти)
local hookerDrop = {}         -- cid -> dropIndex
local hookerTimers = {}       -- cid -> timer
local lastDone = {}           -- questKey -> cid -> os.time()

local function baseOf(jobName)
    return Config.Bases[jobName]
end

local function nearDoor(src, base, distance)
    local pos = GetEntityCoords(GetPlayerPed(src))
    return #(pos - vec3(base.door.x, base.door.y, base.door.z)) <= (distance or 10.0)
end

local function cooldownLeft(questKey, cid, cooldown)
    local last = lastDone[questKey] and lastDone[questKey][cid]
    if last and os.time() - last < cooldown then
        return cooldown - (os.time() - last)
    end
    return 0
end

local function markDone(questKey, cid)
    lastDone[questKey] = lastDone[questKey] or {}
    lastDone[questKey][cid] = os.time()
end

-- Выбор места возрождения: база своей фракции
QBCore.Functions.CreateCallback('bu-factions:server:getSpawns', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local base = baseOf(Player.PlayerData.job.name)
    if not base then return cb({}) end

    cb({ { key = Player.PlayerData.job.name, label = base.label, coords = base.door } })
end)

-- Вход в базу: только своя фракция и рядом с дверью
RegisterNetEvent('bu-factions:server:enterBase', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local base = Config.Bases[key]
    if not base or Player.PlayerData.job.name ~= key then
        TriggerClientEvent('QBCore:Notify', src, 'Это база другой фракции.', 'error')
        return
    end

    if not nearDoor(src, base) then
        TriggerClientEvent('QBCore:Notify', src, 'Подойди ко входу базы.', 'error')
        return
    end

    TriggerClientEvent('bu-factions:client:enter', src, key)
end)

-- Склад фракции
RegisterNetEvent('bu-factions:server:openStash', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local base = Config.Bases[key]
    if not base or Player.PlayerData.job.name ~= key then
        TriggerClientEvent('QBCore:Notify', src, 'Склад доступен только своей фракции.', 'error')
        return
    end

    -- Внутри базы или у двери
    local pos = GetEntityCoords(GetPlayerPed(src))
    local door = vec3(base.door.x, base.door.y, base.door.z)
    local inside = vec3(door.x, door.y, door.z + Config.InteriorZ)
    if #(pos - door) > 25.0 and #(pos - inside) > 25.0 then
        TriggerClientEvent('QBCore:Notify', src, 'Ты не у базы.', 'error')
        return
    end

    exports['qb-inventory']:OpenInventory(src, 'faction-stash-' .. key, {
        maxweight = Config.Stash.maxweight,
        slots = Config.Stash.slots,
        label = base.label .. ' · Склад'
    })
end)

-- Гардероб: только госструктуры
RegisterNetEvent('bu-factions:server:openWardrobe', function(key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local base = Config.Bases[key]
    if not base or base.type ~= 'gov' or Player.PlayerData.job.name ~= key then
        TriggerClientEvent('QBCore:Notify', src, 'Гардероб есть только у госструктур.', 'error')
        return
    end

    TriggerClientEvent('bu-factions:client:openWardrobe', src)
end)

-- ===== Квесты банд =====

RegisterNetEvent('bu-factions:server:startRobbery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local base = baseOf(Player.PlayerData.job.name)
    if not base or base.type ~= 'gang' then
        TriggerClientEvent('QBCore:Notify', src, 'Задания банд — только для участников банды.', 'error')
        return
    end

    local left = cooldownLeft('robbery', Player.PlayerData.citizenid, Config.GangQuests.robbery.cooldown)
    if left > 0 then
        TriggerClientEvent('QBCore:Notify', src, string.format('Задание будет доступно через %d секунд.', left), 'error')
        return
    end

    Player.Functions.AddItem('lockpick', Config.GangQuests.robbery.lockpicks, false)
    activeRobbery[Player.PlayerData.citizenid] = true
    TriggerClientEvent('QBCore:Notify', src, 'Взял отмычки. Взломай дверь дома и обыщи его.', 'primary')
    TriggerClientEvent('bu-factions:client:robberyStarted', src)
end)

RegisterNetEvent('bu-factions:server:robberyDone', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if not activeRobbery[cid] then return end

    activeRobbery[cid] = nil
    markDone('robbery', cid)
    Player.Functions.AddMoney('cash', Config.GangQuests.robbery.reward, 'gang-quest-robbery')
    TriggerClientEvent('QBCore:Notify', src, string.format('Ограбление засчитано: +$%d. Возвращайся на базу через 5 минут.', Config.GangQuests.robbery.reward), 'success')
end)

RegisterNetEvent('bu-factions:server:startCarTheft', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local base = baseOf(Player.PlayerData.job.name)
    if not base or base.type ~= 'gang' then
        TriggerClientEvent('QBCore:Notify', src, 'Задания банд — только для участников банды.', 'error')
        return
    end

    local left = cooldownLeft('cartheft', Player.PlayerData.citizenid, Config.GangQuests.cartheft.cooldown)
    if left > 0 then
        TriggerClientEvent('QBCore:Notify', src, string.format('Задание будет доступно через %d секунд.', left), 'error')
        return
    end

    Player.Functions.AddItem('lockpick', Config.GangQuests.cartheft.lockpicks, false)
    activeCarTheft[Player.PlayerData.citizenid] = true
    TriggerClientEvent('QBCore:Notify', src, 'Взял отмычки. Вскрой машину и угоняй.', 'primary')
    TriggerClientEvent('bu-factions:client:carTheftStarted', src)
end)

RegisterNetEvent('bu-factions:server:carStolen', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if not activeCarTheft[cid] then return end

    carStolen[cid] = true
    TriggerClientEvent('QBCore:Notify', src, 'Машина вскрыта. Отгони её к скупке краденого (метка на карте).', 'primary')
    TriggerClientEvent('bu-factions:client:carStolen', src, Config.GangQuests.cartheft.chop)
end)

RegisterNetEvent('bu-factions:server:carDelivered', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if not carStolen[cid] then return end

    local chop = Config.GangQuests.cartheft.chop
    local pos = GetEntityCoords(GetPlayerPed(src))
    if #(pos - chop) > 25.0 or GetVehiclePedIsIn(GetPlayerPed(src), false) == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Приезжай к скупке на угнанной машине.', 'error')
        return
    end

    carStolen[cid] = nil
    activeCarTheft[cid] = nil
    markDone('cartheft', cid)
    Player.Functions.AddMoney('cash', Config.GangQuests.cartheft.reward, 'gang-quest-cartheft')
    TriggerClientEvent('QBCore:Notify', src, string.format('Машина сдана: +$%d. Возвращайся на базу через 5 минут.', Config.GangQuests.cartheft.reward), 'success')
    TriggerClientEvent('bu-factions:client:carDelivered', src)
end)

-- ===== Квесты мафий =====

RegisterNetEvent('bu-factions:server:startContraband', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local base = baseOf(Player.PlayerData.job.name)
    if not base or base.type ~= 'mafia' then
        TriggerClientEvent('QBCore:Notify', src, 'Задания мафий — только для участников мафии.', 'error')
        return
    end

    local left = cooldownLeft('contraband', Player.PlayerData.citizenid, Config.MafiaQuests.contraband.cooldown)
    if left > 0 then
        TriggerClientEvent('QBCore:Notify', src, string.format('Задание будет доступно через %d секунд.', left), 'error')
        return
    end

    local spotIndex = math.random(#Config.DarkSpots)
    contrabandJob[Player.PlayerData.citizenid] = spotIndex

    Player.Functions.AddItem('contraband', 1, false)
    TriggerClientEvent('QBCore:Notify', src, 'Товар у тебя. Тёмный покупатель ждёт — метка на карте.', 'primary')
    TriggerClientEvent('bu-factions:client:contrabandTarget', src, spotIndex, Config.DarkSpots[spotIndex].coords)
end)

RegisterNetEvent('bu-factions:server:deliverContraband', function(spotIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if not contrabandJob[cid] or contrabandJob[cid] ~= tonumber(spotIndex) then return end

    local spot = Config.DarkSpots[tonumber(spotIndex)]
    local pos = GetEntityCoords(GetPlayerPed(src))
    if #(pos - vec3(spot.coords.x, spot.coords.y, spot.coords.z)) > 5.0 then
        TriggerClientEvent('QBCore:Notify', src, 'Подойди к покупателю.', 'error')
        return
    end

    local removed = Player.Functions.RemoveItem('contraband', 1, false)
    if not removed then
        TriggerClientEvent('QBCore:Notify', src, 'У тебя нет контрабанды.', 'error')
        return
    end

    contrabandJob[cid] = nil
    markDone('contraband', cid)
    Player.Functions.AddMoney('cash', Config.MafiaQuests.contraband.reward, 'mafia-quest-contraband')
    TriggerClientEvent('QBCore:Notify', src, string.format('Контрабанда сдана: +$%d. Следующая партия через 3 минуты.', Config.MafiaQuests.contraband.reward), 'success')
    TriggerClientEvent('bu-factions:client:contrabandDone', src)
end)

RegisterNetEvent('bu-factions:server:startHooker', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local base = baseOf(Player.PlayerData.job.name)
    if not base or base.type ~= 'mafia' then
        TriggerClientEvent('QBCore:Notify', src, 'Задания мафий — только для участников мафии.', 'error')
        return
    end

    local left = cooldownLeft('hooker', Player.PlayerData.citizenid, Config.MafiaQuests.hooker.cooldown)
    if left > 0 then
        TriggerClientEvent('QBCore:Notify', src, string.format('Задание будет доступно через %d секунд.', left), 'error')
        return
    end

    local cid = Player.PlayerData.citizenid
    hookerState[cid] = 1
    hookerDrop[cid] = math.random(#Config.Hooker.drops)

    TriggerClientEvent('QBCore:Notify', src, 'Забери девушку у мотеля — метка на карте. Нужна машина.', 'primary')
    TriggerClientEvent('bu-factions:client:hookerStage1', src, Config.Hooker.pickup)

    hookerTimers[cid] = SetTimeout(Config.MafiaQuests.hooker.timeout * 1000, function()
        if hookerState[cid] then
            hookerState[cid] = nil
            hookerDrop[cid] = nil
            TriggerClientEvent('QBCore:Notify', src, 'Задание провалено: время вышло.', 'error')
            TriggerClientEvent('bu-factions:client:hookerDone', src, false)
        end
    end)
end)

RegisterNetEvent('bu-factions:server:hookerPickup', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if hookerState[cid] ~= 1 then return end

    local pickup = Config.Hooker.pickup
    local pos = GetEntityCoords(GetPlayerPed(src))
    if #(pos - vec3(pickup.x, pickup.y, pickup.z)) > 10.0 then
        TriggerClientEvent('QBCore:Notify', src, 'Девушка ждёт у мотеля.', 'error')
        return
    end

    if GetVehiclePedIsIn(GetPlayerPed(src), false) == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Приезжай на машине — девушка сядет в неё.', 'error')
        return
    end

    hookerState[cid] = 2
    TriggerClientEvent('QBCore:Notify', src, 'Клиент ждёт по адресу — метка на карте.', 'primary')
    TriggerClientEvent('bu-factions:client:hookerStage2', src, Config.Hooker.drops[hookerDrop[cid]])
end)

RegisterNetEvent('bu-factions:server:hookerDeliver', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if hookerState[cid] ~= 2 then return end

    local drop = Config.Hooker.drops[hookerDrop[cid]]
    local pos = GetEntityCoords(GetPlayerPed(src))
    if #(pos - drop) > 15.0 then
        TriggerClientEvent('QBCore:Notify', src, 'Подвези девушку ближе к адресу.', 'error')
        return
    end

    hookerState[cid] = nil
    hookerDrop[cid] = nil
    if hookerTimers[cid] then
        ClearTimeout(hookerTimers[cid])
        hookerTimers[cid] = nil
    end
    markDone('hooker', cid)

    Player.Functions.AddMoney('cash', Config.MafiaQuests.hooker.reward, 'mafia-quest-hooker')
    TriggerClientEvent('QBCore:Notify', src, string.format('Клиент доволен: +$%d. Следующий заказ через 3 минуты.', Config.MafiaQuests.hooker.reward), 'success')
    TriggerClientEvent('bu-factions:client:hookerDone', src, true)
end)

-- Очистка состояний при выходе
AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    activeRobbery[cid] = nil
    activeCarTheft[cid] = nil
    carStolen[cid] = nil
    contrabandJob[cid] = nil
    hookerState[cid] = nil
    hookerDrop[cid] = nil
    if hookerTimers[cid] then
        ClearTimeout(hookerTimers[cid])
        hookerTimers[cid] = nil
    end
end)
