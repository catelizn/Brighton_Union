local QBCore = exports['qb-core']:GetCoreObject()

local insideKey = nil
local shellObjects = {}
local interiorPointIds = {}

local questRobbery = false
local questCarTheft = false
local chopPointId = nil
local chopBlip = nil

local contrabandPointId = nil
local contrabandBlip = nil
local contrabandSpot = nil

local hookerActive = false
local hookerPointId = nil
local hookerBlip = nil
local hookerPed = nil

local function cleanupInteriorPoints()
    for _, id in ipairs(interiorPointIds) do
        exports['bu-interact']:removePoint(id)
    end
    interiorPointIds = {}
end

local function leaveBase()
    local base = Config.Bases[insideKey]
    DoScreenFadeOut(400)
    Wait(500)
    exports['qb-interior']:DespawnInterior(shellObjects, function()
        shellObjects = {}
        cleanupInteriorPoints()
        SetEntityCoords(PlayerPedId(), base.door.x, base.door.y, base.door.z)
        SetEntityHeading(PlayerPedId(), base.door.w)
        insideKey = nil
        DoScreenFadeIn(600)
    end)
end

-- Вход в базу: строим интерьер под землёй и телепортируем внутрь
RegisterNetEvent('bu-factions:client:enter', function(key)
    local base = Config.Bases[key]
    if not base then return end

    local door = base.door
    local origin = vector3(door.x, door.y, door.z + Config.InteriorZ)
    local exit = base.interior.exit

    local result = exports['qb-interior']:CreateShell(origin, { x = exit.x, y = exit.y, z = exit.z, h = exit.w }, base.interior.model)
    shellObjects = result[1]
    insideKey = key

    local inside = vector3(origin.x + exit.x, origin.y + exit.y, origin.z + exit.z)

    interiorPointIds[#interiorPointIds + 1] = exports['bu-interact']:addPoint(inside, 1.5, {
        label = 'Выйти из базы',
        size = 1.0,
        action = function() leaveBase() end
    })

    local stash = Config.InteriorStash
    interiorPointIds[#interiorPointIds + 1] = exports['bu-interact']:addPoint(
        vec3(inside.x + stash.x, inside.y + stash.y, inside.z + stash.z), 1.5, {
            label = Config.Stash.labelSuffix,
            size = 1.0,
            action = function() TriggerServerEvent('bu-factions:server:openStash', key) end
        })

    if base.wardrobe then
        local wardrobe = Config.InteriorWardrobe
        interiorPointIds[#interiorPointIds + 1] = exports['bu-interact']:addPoint(
            vec3(inside.x + wardrobe.x, inside.y + wardrobe.y, inside.z + wardrobe.z), 1.5, {
                label = Config.Wardrobe.labelSuffix,
                size = 1.0,
                action = function() TriggerServerEvent('bu-factions:server:openWardrobe', key) end
            })
    end
end)

RegisterNetEvent('bu-factions:client:openWardrobe', function()
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end)

-- ===== Базы на карте, NPC и квесты =====
local baseSetupDone = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if baseSetupDone then return end
    baseSetupDone = true

    for key, base in pairs(Config.Bases) do
        local door = vec3(base.door.x, base.door.y, base.door.z)

        -- Вход
        exports['bu-interact']:addPoint(door, 1.2, {
            label = 'Войти — ' .. base.label,
            size = 1.0,
            action = function() TriggerServerEvent('bu-factions:server:enterBase', key) end
        })

        -- База на карте
        exports['bu-interact']:addBlip(door, {
            sprite = base.blipSprite,
            color = base.color,
            scale = 0.7,
            name = base.label,
            shortRange = false
        })

        -- Склад на карте (у всех фракций)
        exports['bu-interact']:addBlip(vec3(door.x + 2.0, door.y, door.z), {
            sprite = Config.Stash.blipSprite,
            color = Config.Stash.blipColor,
            scale = 0.6,
            name = base.label .. ' · ' .. Config.Stash.labelSuffix,
            shortRange = false
        })

        -- Гардероб на карте (только госструктуры)
        if base.wardrobe then
            exports['bu-interact']:addBlip(vec3(door.x - 2.0, door.y, door.z), {
                sprite = Config.Wardrobe.blipSprite,
                color = Config.Wardrobe.blipColor,
                scale = 0.6,
                name = base.label .. ' · ' .. Config.Wardrobe.labelSuffix,
                shortRange = false
            })
        end

        -- NPC на базе
        if base.type == 'gang' then
            exports['bu-interact']:spawnPed(base.questModel, vec4(door.x + 1.8, door.y - 2.5, door.z, base.door.w), {
                label = Config.GangQuests.robbery.label,
                scenario = Config.NpcScenario,
                action = function() TriggerServerEvent('bu-factions:server:startRobbery') end
            })
            exports['bu-interact']:spawnPed(base.questModel, vec4(door.x - 1.8, door.y - 2.5, door.z, base.door.w), {
                label = Config.GangQuests.cartheft.label,
                scenario = Config.NpcScenario,
                action = function() TriggerServerEvent('bu-factions:server:startCarTheft') end
            })
        elseif base.type == 'mafia' then
            exports['bu-interact']:spawnPed(base.questModel, vec4(door.x + 1.8, door.y - 2.5, door.z, base.door.w), {
                label = Config.MafiaQuests.contraband.label,
                scenario = Config.NpcScenario,
                action = function() TriggerServerEvent('bu-factions:server:startContraband') end
            })
            exports['bu-interact']:spawnPed(base.questModel, vec4(door.x - 1.8, door.y - 2.5, door.z, base.door.w), {
                label = Config.MafiaQuests.hooker.label,
                scenario = Config.NpcScenario,
                action = function() TriggerServerEvent('bu-factions:server:startHooker') end
            })
        else
            exports['bu-interact']:spawnPed(base.questModel, vec4(door.x, door.y - 2.5, door.z, base.door.w), {
                label = Config.ClerkLabel .. ' · ' .. base.label,
                scenario = Config.NpcScenario,
                action = nil
            })
        end
    end

    -- Тёмные покупатели: стоят в укромных местах, сдают только по заданию
    for i = 1, #Config.DarkSpots do
        exports['bu-interact']:spawnPed(Config.DarkSpots[i].model, Config.DarkSpots[i].coords, {
            label = '',
            scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
            action = nil
        })
    end

    -- Девушка у мотеля
    exports['bu-interact']:spawnPed(Config.Hooker.model, Config.Hooker.pickup, {
        label = '',
        scenario = 'WORLD_HUMAN_LEANING',
        action = function()
            if hookerActive then
                TriggerServerEvent('bu-factions:server:hookerPickup')
            end
        end
    })
end)

-- ===== Квесты банд =====

RegisterNetEvent('bu-factions:client:robberyStarted', function()
    questRobbery = true
end)

-- Успешное проникновение в дом (qb-houserobbery)
RegisterNetEvent('qb-houserobbery:client:enterHouse', function()
    if not questRobbery then return end
    questRobbery = false
    TriggerServerEvent('bu-factions:server:robberyDone')
end)

RegisterNetEvent('bu-factions:client:carTheftStarted', function()
    questCarTheft = true
end)

-- Отмычка сработала: проверяем, что рядом машина (а не дверь дома)
RegisterNetEvent('lockpicks:UseLockpick', function()
    if not questCarTheft then return end
    CreateThread(function()
        Wait(2000)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local veh = GetVehiclePedIsIn(ped, false)
        if veh == 0 then
            veh = GetClosestVehicle(pos.x, pos.y, pos.z, 4.0, 0, 70)
        end
        if veh and veh ~= 0 then
            questCarTheft = false
            TriggerServerEvent('bu-factions:server:carStolen')
        end
    end)
end)

RegisterNetEvent('bu-factions:client:carStolen', function(chop)
    if chopPointId then exports['bu-interact']:removePoint(chopPointId) end
    if chopBlip then RemoveBlip(chopBlip) end

    chopPointId = exports['bu-interact']:addPoint(vec3(chop.x, chop.y, chop.z), 4.0, {
        label = 'Сдать угнанную машину',
        size = 1.2,
        action = function() TriggerServerEvent('bu-factions:server:carDelivered') end
    })
    chopBlip = exports['bu-interact']:addBlip(vec3(chop.x, chop.y, chop.z), {
        sprite = 408, color = 1, scale = 0.7, name = 'Скупка краденого'
    })
    SetBlipRoute(chopBlip, true)
end)

RegisterNetEvent('bu-factions:client:carDelivered', function()
    if chopPointId then exports['bu-interact']:removePoint(chopPointId) end
    if chopBlip then RemoveBlip(chopBlip) end
    chopPointId = nil
    chopBlip = nil
end)

-- ===== Квесты мафий =====

RegisterNetEvent('bu-factions:client:contrabandTarget', function(spotIndex, coords)
    if contrabandPointId then exports['bu-interact']:removePoint(contrabandPointId) end
    if contrabandBlip then RemoveBlip(contrabandBlip) end

    contrabandSpot = spotIndex
    contrabandPointId = exports['bu-interact']:addPoint(vec3(coords.x, coords.y, coords.z), 3.0, {
        label = 'Сдать контрабанду',
        size = 1.2,
        action = function() TriggerServerEvent('bu-factions:server:deliverContraband', spotIndex) end
    })
    contrabandBlip = exports['bu-interact']:addBlip(vec3(coords.x, coords.y, coords.z), {
        sprite = 408, color = 6, scale = 0.7, name = 'Покупатель контрабанды'
    })
    SetBlipRoute(contrabandBlip, true)
end)

RegisterNetEvent('bu-factions:client:contrabandDone', function()
    if contrabandPointId then exports['bu-interact']:removePoint(contrabandPointId) end
    if contrabandBlip then RemoveBlip(contrabandBlip) end
    contrabandPointId = nil
    contrabandBlip = nil
    contrabandSpot = nil
end)

RegisterNetEvent('bu-factions:client:hookerStage1', function(pickup)
    hookerActive = true
    hookerBlip = exports['bu-interact']:addBlip(vec3(pickup.x, pickup.y, pickup.z), {
        sprite = 225, color = 5, scale = 0.7, name = 'Забрать девушку'
    })
    SetBlipRoute(hookerBlip, true)
end)

RegisterNetEvent('bu-factions:client:hookerStage2', function(drop)
    hookerActive = false
    if hookerBlip then RemoveBlip(hookerBlip) end
    hookerBlip = nil

    hookerPointId = exports['bu-interact']:addPoint(vec3(drop.x, drop.y, drop.z), 5.0, {
        label = 'Высадить клиентку',
        size = 1.2,
        action = function() TriggerServerEvent('bu-factions:server:hookerDeliver') end
    })

    -- Девушка садится в машину
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local model = Config.Hooker.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local pos = GetEntityCoords(ped)
    hookerPed = CreatePed(0, model, pos.x + 1.5, pos.y, pos.z, GetEntityHeading(ped), false, false)
    SetBlockingOfNonTemporaryEvents(hookerPed, true)
    SetPedFleeAttributes(hookerPed, 0, false)
    TaskEnterVehicle(hookerPed, veh, 10000, -2, 1.0, 1, 0)

    hookerBlip = exports['bu-interact']:addBlip(vec3(drop.x, drop.y, drop.z), {
        sprite = 225, color = 5, scale = 0.7, name = 'Адрес клиента'
    })
    SetBlipRoute(hookerBlip, true)
end)

RegisterNetEvent('bu-factions:client:hookerDone', function(success)
    hookerActive = false
    if hookerPointId then exports['bu-interact']:removePoint(hookerPointId) end
    if hookerBlip then RemoveBlip(hookerBlip) end
    hookerPointId = nil
    hookerBlip = nil

    if hookerPed and DoesEntityExist(hookerPed) then
        local veh = GetVehiclePedIsIn(hookerPed, false)
        if veh ~= 0 then
            TaskLeaveVehicle(hookerPed, veh, 1)
            Wait(1500)
        end
        DeleteEntity(hookerPed)
    end
    hookerPed = nil
end)
