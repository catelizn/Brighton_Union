-- Общая библиотека интеракций: NPC, маркеры с подсказкой [E], блипы.
-- Все точки держим на клиенте: для 2000 игроков это дёшево, потому что
-- в кадре обрабатываются только объекты рядом с игроком.

local points = {}
local peds = {}
local nextPointId = 0

local function groundZ(x, y, z)
    local found, ground = GetGroundZFor_3dCoord(x, y, z + 200.0, false)
    return found and ground or z
end

local function drawText3D(coords, text)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 1.05)
    if not onScreen then return end
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(226, 232, 240, 235)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(screenX, screenY)
end

local function drawPoint(point, playerPos)
    local dist = #(playerPos - point.coords)
    if dist > point.radius + 12.0 then return false end

    local color = point.color
    DrawMarker(1, point.coords.x, point.coords.y, point.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        point.size, point.size, point.size, color[1], color[2], color[3], color[4],
        false, true, 2, false, nil, nil, false)

    if dist <= point.radius and point.label ~= '' then
        if not point.canInteract or point.canInteract() then
            drawText3D(point.coords, point.label .. '  [E]')
            if IsControlJustPressed(0, 38) and point.action then
                point.action()
            end
        end
    end

    return true
end

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local busy = false

        for _, point in pairs(points) do
            if drawPoint(point, playerPos) then busy = true end
        end

        for ped, data in pairs(peds) do
            if DoesEntityExist(ped) then
                local pedPos = GetEntityCoords(ped)
                local dist = #(playerPos - pedPos)
                if dist <= 12.0 then
                    busy = true
                    if dist <= 2.2 and data.action then
                        drawText3D(pedPos, data.label .. '  [E]')
                        if IsControlJustPressed(0, 38) then
                            data.action()
                        end
                    end
                end
            end
        end

        if not busy then Wait(150) end
    end
end)

local function addBlip(coords, opts)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, opts.sprite or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, opts.scale or 0.7)
    SetBlipColour(blip, opts.color or 2)
    if opts.shortRange ~= false then
        SetBlipAsShortRange(blip, true)
    end
    if opts.name then
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(opts.name)
        EndTextCommandSetBlipName(blip)
    end
    return blip
end

exports('addBlip', addBlip)

exports('spawnPed', function(model, coords, opts)
    opts = opts or {}
    local x, y = coords.x, coords.y
    local z = opts.snapZ == false and coords.z or groundZ(x, y, coords.z or 0.0)
    local heading = coords.w or opts.heading or 0.0

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(0, model, x, y, z, heading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if opts.scenario then
        TaskStartScenarioInPlace(ped, opts.scenario, 0, true)
    end

    if opts.anim then
        RequestAnimDict(opts.anim.dict)
        while not HasAnimDictLoaded(opts.anim.dict) do Wait(0) end
        TaskPlayAnim(ped, opts.anim.dict, opts.anim.name, 8.0, -8.0, -1, opts.anim.flag or 1, 0, false, false, false)
    end

    peds[ped] = {
        label = opts.label or '',
        action = opts.action
    }

    if opts.blip then
        addBlip(vec3(x, y, z), opts.blip)
    end

    return ped
end)

exports('removePed', function(ped)
    if peds[ped] then
        peds[ped] = nil
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)

exports('addPoint', function(coords, radius, opts)
    opts = opts or {}
    nextPointId = nextPointId + 1
    points[nextPointId] = {
        coords = vec3(coords.x, coords.y, groundZ(coords.x, coords.y, coords.z or 0.0)),
        radius = radius or 1.0,
        size = opts.size or 1.0,
        label = opts.label or '',
        action = opts.action,
        canInteract = opts.canInteract,
        color = opts.color or { 46, 90, 68, 150 }
    }
    return nextPointId
end)

exports('removePoint', function(id)
    points[id] = nil
end)
