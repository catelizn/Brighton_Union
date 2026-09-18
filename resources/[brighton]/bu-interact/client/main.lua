-- Общая библиотека интеракций: NPC, маркеры с подсказкой [E], блипы.
-- Все точки держим на клиенте: для 2000 игроков это дёшево, потому что
-- в кадре обрабатываются только объекты рядом с игроком.

local points = {}
local peds = {}
local nextPointId = 0

local function groundZ(x, y, z)
    -- Заглушка z=0: высота неизвестна, ищем землю с большой высоты
    if z <= 0.5 then
        local found, ground = GetGroundZFor_3dCoord(x, y, z + 200.0, true)
        return found and ground or z
    end

    -- Иначе ищем землю строго рядом с указанной высотой: координаты в конфигах
    -- уже сняты с земли. Луч пускаем чуть выше уровня ног и принимаем только
    -- высоты не выше конфига: иначе в аэропорту ЛС луч цепляет козырёк
    -- над точкой, и NPC «висит в воздухе».
    local found, ground = GetGroundZFor_3dCoord(x, y, z + 0.5, true)
    if found and ground >= z - 3.0 and ground <= z + 0.8 then
        return ground
    end

    return z
end

local function drawText3D(coords, text)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 1.05)
    if not onScreen then return end
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextColour(233, 238, 243, 235)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(screenX, screenY)
end

local function drawPointMarker(point, playerPos)
    local dist = #(playerPos - point.coords)
    if dist > point.radius + 12.0 then return false end

    local color = point.color
    DrawMarker(1, point.coords.x, point.coords.y, point.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        point.size, point.size, point.size, color[1], color[2], color[3], color[4],
        false, true, 2, false, nil, nil, false)

    return true
end

-- Подсказка о взаимодействии рисуется NUI-плашкой (округлая, аккуратная),
-- сообщение в UI уходит только при смене текста
local lastHintText = nil

local function showHint(text)
    if text == lastHintText then return end
    lastHintText = text
    SendNUIMessage({ type = 'bu:hint', text = text or '' })
end

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local busy = false
        local uiBusy = IsNuiFocused() or IsPauseMenuActive()

        -- Находим по одной ближайшей цели среди точек и NPC: реагирует на E
        -- и показывает подсказку только она, иначе магазины, бизнесы и NPC
        -- в одной точке перетягивают клавишу друг у друга.
        local bestPoint, bestPointDist = nil, nil
        for _, point in pairs(points) do
            if drawPointMarker(point, playerPos) then busy = true end

            local dist = #(playerPos - point.coords)
            local canUse = not point.canInteract or point.canInteract()
            if dist <= point.radius and point.label ~= '' and canUse then
                if not bestPointDist or dist < bestPointDist then
                    bestPointDist, bestPoint = dist, point
                end
            end
        end

        local bestPed, bestPedDist, bestPedData = nil, nil, nil
        for ped, data in pairs(peds) do
            if DoesEntityExist(ped) then
                local pedPos = GetEntityCoords(ped)
                local dist = #(playerPos - pedPos)
                -- Рядом с игроком периодически поправляем высоту: коллизии
                -- интерьеров и улиц стримятся с задержкой, от этого NPC «висели»
                if dist <= 25.0 and GetGameTimer() > (data.nextSnap or 0) then
                    data.nextSnap = GetGameTimer() + 1500
                    local found, ground = GetGroundZFor_3dCoord(pedPos.x, pedPos.y, pedPos.z + 0.6, true)
                    -- Поднимаем всегда (иначе NPC висит в воздухе), опускаем только
                    -- на пару сантиметров: луч из точки над тротуаром часто находит
                    -- дорогу под ним, и от этого NPC уходил в землю по колено.
                    if found then
                        local diff = ground - pedPos.z
                        if diff > -0.25 and diff < 6.0 then
                            SetEntityCoordsNoOffset(ped, pedPos.x, pedPos.y, ground, false, false, false)
                            FreezeEntityPosition(ped, true)
                        end
                    end
                end
                if dist <= 12.0 then
                    busy = true
                    -- Имя NPC видно только в прямой видимости (без просвета через стены)
                    if data.plate and dist <= data.plate.range and HasEntityClearLosToEntity(playerPed, ped, 17) then
                        drawText3D(pedPos, data.plate.text)
                    end
                    if dist <= 2.2 and data.action then
                        if not bestPedDist or dist < bestPedDist then
                            bestPedDist, bestPed, bestPedData = dist, ped, data
                        end
                    end
                end
            end
        end
        if bestPed ~= nil and not DoesEntityExist(bestPed) then bestPed = nil end

        local hint, action
        if bestPedData and (not bestPointDist or bestPedDist <= bestPointDist) then
            hint = bestPedData.hint or bestPedData.label
            action = bestPedData.action
        elseif bestPoint then
            hint = bestPoint.hint or bestPoint.label
            action = bestPoint.action
            drawText3D(bestPoint.coords, bestPoint.label)
        end

        if hint and hint ~= '' and not uiBusy then
            showHint(hint)
            if action and IsControlJustPressed(0, 38) then
                action()
            end
        else
            showHint('')
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
    -- Высоту из конфига не пересчитываем: координаты уже сняты с земли, а луч
    -- под тротуаром находит дорогу и тянет NPC вниз. Землю ищем только там,
    -- где высота неизвестна (z <= 0.5).
    local z = coords.z or 0.0
    if opts.snapZ ~= false and z <= 0.5 then
        z = groundZ(x, y, z)
    end
    local heading = coords.w or opts.heading or 0.0

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(0, model, x, y, z, heading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Если коллизии ещё не стримнулись и NPC оказался ниже земли — поднимаем
    SetTimeout(1500, function()
        if not DoesEntityExist(ped) then return end
        local current = GetEntityCoords(ped)
        local found, ground = GetGroundZFor_3dCoord(current.x, current.y, current.z + 0.6, true)
        if found and ground > current.z then
            SetEntityCoordsNoOffset(ped, current.x, current.y, ground, false, false, false)
        end
        FreezeEntityPosition(ped, true)
    end)

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
        hint = opts.hint,
        plate = opts.plate,
        action = opts.action
    }

    -- Продавцы и банкиры должны смотреть на посетителя, а не в стену
    if opts.face then
        CreateThread(function()
            while DoesEntityExist(ped) do
                Wait(600)
                local pedPos = GetEntityCoords(ped)
                local closest, closestDist
                for _, player in ipairs(GetActivePlayers()) do
                    local targetPos = GetEntityCoords(GetPlayerPed(player))
                    local dist = #(targetPos - pedPos)
                    if dist < 6.0 and (not closestDist or dist < closestDist) then
                        closest, closestDist = targetPos, dist
                    end
                end
                if closest then
                    SetEntityHeading(ped, GetHeadingFromVector_2d(closest.x - pedPos.x, closest.y - pedPos.y))
                end
            end
        end)
    end

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
        hint = opts.hint,
        action = opts.action,
        canInteract = opts.canInteract,
        color = opts.color or { 47, 143, 131, 150 }
    }
    return nextPointId
end)

exports('removePoint', function(id)
    points[id] = nil
end)
