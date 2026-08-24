local QBCore = exports['qb-core']:GetCoreObject()

local hallObjects = {}
local inHall = false

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
    exports['qb-target']:AddCircleZone('bu_auction_exit', vec3(exitPoint.x, exitPoint.y, exitPoint.z), 1.2, {
        name = 'bu_auction_exit',
        useZ = true,
        debugPoly = false
    }, {
        options = {
            {
                icon = 'fas fa-door-open',
                label = Config.ExitLabel,
                action = function()
                    leaveHall()
                end
            }
        },
        distance = 2.0
    })

    Wait(400)
    openMenu()
end

local function leaveHall()
    if not inHall then return end

    exports['qb-target']:RemoveZone('bu_auction_exit')
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

    local blip = AddBlipForCoord(door.x, door.y, door.z)
    SetBlipSprite(blip, Config.Hall.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Hall.blip.scale)
    SetBlipColour(blip, Config.Hall.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Hall.blip.name)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddCircleZone('bu_auction_door', vec3(door.x, door.y, door.z), 1.0, {
        name = 'bu_auction_door',
        useZ = true,
        debugPoly = false
    }, {
        options = {
            {
                icon = 'fas fa-gavel',
                label = Config.TargetLabel,
                action = function()
                    enterHall()
                end
            }
        },
        distance = 2.0
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
    TriggerServerEvent('bu-auction:server:bid', data.id)
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
