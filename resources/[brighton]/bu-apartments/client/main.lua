local QBCore = exports['qb-core']:GetCoreObject()

local inside = false
local currentBuilding = nil
local currentFlat = 0
local houseObjects = {}

local function openMenu()
    if inside then return end
    QBCore.Functions.TriggerCallback('bu-apartments:server:getBuilding', function(data)
        if not data then return end
        currentBuilding = data
        SendNUIMessage({ type = 'bu:apartments:open', data = data, inside = false })
        SetNuiFocus(true, true)
    end, currentBuildingKey())
end

local function currentBuildingKey()
    local playerPos = GetEntityCoords(PlayerPedId())
    local bestKey = nil
    local bestDistance = 3.5
    for i = 1, #Config.Buildings do
        local building = Config.Buildings[i]
        local door = building.door
        local distance = #(playerPos - vec3(door.x, door.y, door.z))
        if distance <= bestDistance then
            bestKey = building.key
            bestDistance = distance
        end
    end
    return bestKey
end

local function interiorCoords(building, number)
    local door = building.door
    local offset = Config.InteriorOffsetBase + number * Config.InteriorOffsetStep
    return { x = door.x, y = door.y, z = door.z - offset }
end

local function shellFor(interiorId)
    local interiors = currentBuilding and currentBuilding.interiors or Config.Interiors
    for i = 1, #interiors do
        if interiors[i].id == interiorId then return interiors[i].shell end
    end
    return 'CreateApartmentFurnished'
end

local function spawnFlatObjects(building, number, coords)
    local flat = building.flats[number]
    local interiorId = flat and flat.interior or 'standard'
    local result = exports['qb-interior'][shellFor(interiorId)](coords)
    if result and result[1] then
        houseObjects = result[1]
    end
end

local function leaveApartment()
    if not inside then return end

    DoScreenFadeOut(400)
    Wait(500)

    exports['qb-interior']:DespawnInterior(houseObjects, function()
        houseObjects = {}
    end)

    local building = currentBuilding
    SetEntityCoords(PlayerPedId(), building.door.x, building.door.y, building.door.z)
    SetEntityHeading(PlayerPedId(), building.door.w)

    inside = false
    currentFlat = 0
    DoScreenFadeIn(600)
    SendNUIMessage({ type = 'bu:apartments:close' })
    SetNuiFocus(false, false)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    for i = 1, #Config.Buildings do
        local building = Config.Buildings[i]
        local door = building.door

        exports['bu-interact']:addPoint(vec3(door.x, door.y, door.z), 1.0, {
            label = Config.TargetLabel .. ': ' .. building.label,
            action = function()
                openMenu()
            end
        })

        exports['bu-interact']:addBlip(vec3(door.x, door.y, door.z), {
            sprite = 475,
            color = 2,
            scale = 0.7,
            name = building.label,
            shortRange = false
        })
    end
end)

RegisterNetEvent('bu-apartments:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

RegisterNUICallback('buy', function(data, cb)
    TriggerServerEvent('bu-apartments:server:buy', data.building, data.number)
    SetTimeout(900, openMenu)
    cb('ok')
end)

RegisterNUICallback('enter', function(data, cb)
    SetNuiFocus(false, false)

    local building = currentBuilding
    local number = tonumber(data.number)
    if not building or not number then return cb('ok') end

    DoScreenFadeOut(400)
    Wait(500)

    local coords = interiorCoords(building, number)
    spawnFlatObjects(building, number, coords)

    inside = true
    currentFlat = number
    DoScreenFadeIn(600)

    SendNUIMessage({
        type = 'bu:apartments:open',
        data = building,
        inside = true,
        flat = number
    })
    SetNuiFocus(true, true)
    cb('ok')
end)

-- Покупка мебели из меню квартиры
RegisterNUICallback('interior', function(data, cb)
    TriggerServerEvent('bu-apartments:server:buyInterior', currentBuilding.key, currentFlat, data.interior)
    cb('ok')
end)

-- Мебель куплена: перестраиваем интерьер прямо под игроком
RegisterNetEvent('bu-apartments:client:interiorChanged', function(interiorId)
    if not inside or not currentBuilding then return end
    currentBuilding.flats[currentFlat].interior = interiorId
    exports['qb-interior']:DespawnInterior(houseObjects, function()
        houseObjects = {}
        spawnFlatObjects(currentBuilding, currentFlat, interiorCoords(currentBuilding, currentFlat))
    end)
end)

RegisterNUICallback('leave', function(_, cb)
    leaveApartment()
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    if inside then
        leaveApartment()
    else
        SetNuiFocus(false, false)
        SendNUIMessage({ type = 'bu:apartments:close' })
    end
    cb('ok')
end)
