local QBCore = exports['qb-core']:GetCoreObject()

local hallObjects = {}
local inHall = false
local exitPointId = nil

local function hallSpawn()
    local door = Config.Hall.door
    return vec3(door.x, door.y, door.z - Config.Hall.interiorOffsetZ)
end

local function enterHall()
    if inHall then return end

    local spawn = hallSpawn()
    local result = exports['qb-interior']:CreateOfficeBig(spawn)
    if result and result[1] then
        hallObjects = result[1]
    end

    inHall = true

    local exitPoint = spawn + Config.Hall.exitOffset
    exitPointId = exports['bu-interact']:addPoint(vec3(exitPoint.x, exitPoint.y, exitPoint.z), 1.2, {
        label = Config.ExitLabel,
        color = { 214, 69, 69, 150 },
        action = leaveHall
    })

    Wait(400)
    openMenu()
end

local function leaveHall()
    if not inHall then return end

    if exitPointId then
        exports['bu-interact']:removePoint(exitPointId)
        exitPointId = nil
    end
    SendNUIMessage({ type = 'bu:auction:close' })
    SetNuiFocus(false, false)

    DoScreenFadeOut(400)
    Wait(500)

    exports['qb-interior']:DespawnInterior(hallObjects, function()
        hallObjects = {}
    end)

    local door = Config.Hall.door
    SetEntityCoords(PlayerPedId(), door.x, door.y, door.z)
    SetEntityHeading(PlayerPedId(), door.w)

    inHall = false
    DoScreenFadeIn(600)
end

local function openMenu()
    QBCore.Functions.TriggerCallback('bu-auction:server:getAuctions', function(auctions)
        QBCore.Functions.TriggerCallback('bu-auction:server:getMyLots', function(myLots)
            SendNUIMessage({ type = 'bu:auction:open', auctions = auctions, myLots = myLots })
            SetNuiFocus(true, true)
        end)
    end)
end

local function setupDoor()
    local door = Config.Hall.door

    exports['bu-interact']:addBlip(vec3(door.x, door.y, door.z), Config.Hall.blip)
    exports['bu-interact']:addPoint(vec3(door.x, door.y, door.z), 1.0, {
        label = Config.TargetLabel,
        action = enterHall
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', setupDoor)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    setupDoor()
end)

RegisterNetEvent('bu-auction:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

RegisterNUICallback('refresh', function(_, cb)
    openMenu()
    cb('ok')
end)

RegisterNUICallback('create', function(data, cb)
    TriggerServerEvent('bu-auction:server:create', data.lotType, data.lotKey, data.label, data.price, data.duration, data.itemName, data.itemAmount)
    SetTimeout(800, openMenu)
    cb('ok')
end)

RegisterNUICallback('bid', function(data, cb)
    TriggerServerEvent('bu-auction:server:bid', data.id, data.mult)
    SetTimeout(800, openMenu)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    if inHall then
        leaveHall()
    else
        SetNuiFocus(false, false)
        SendNUIMessage({ type = 'bu:auction:close' })
    end
    cb('ok')
end)
