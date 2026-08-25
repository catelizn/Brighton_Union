local QBCore = exports['qb-core']:GetCoreObject()

local npc = nil
local pendingArrival = false

local function openTutorial()
    QBCore.Functions.TriggerCallback('bu-tutorial:server:getState', function(state)
        if not state then return end
        SendNUIMessage({
            type = 'bu:tutorial:open',
            data = {
                npcName = Config.Quest.npcName,
                label = Config.Quest.label,
                stages = Config.Quest.stages,
                stage = state.stage,
                completed = state.completed
            }
        })
        SetNuiFocus(true, true)
    end)
end

local function spawnNpc()
    if npc then return end
    npc = exports['bu-interact']:spawnPed(Config.NPC.model, Config.NPC.coords, {
        label = Config.TargetLabel,
        scenario = Config.NPC.scenario,
        anim = Config.NPC.anim,
        blip = Config.NPC.blip,
        action = openTutorial
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnNpc()
    QBCore.Functions.TriggerCallback('bu-tutorial:server:getState', function(state)
        if state and state.isNew then pendingArrival = true end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    spawnNpc()
end)

-- Персонаж создан и подтверждён: прилёт в аэропорт
RegisterNetEvent('qb-clothing:client:onMenuClose', function()
    if not pendingArrival then return end
    pendingArrival = false
    TriggerEvent('bu-tutorial:client:arrival')
end)

RegisterNetEvent('bu-tutorial:client:update', function(stage, completed)
    SendNUIMessage({
        type = 'bu:tutorial:update',
        data = { stage = stage, completed = completed }
    })
end)

RegisterNetEvent('bu-tutorial:client:notify', function(message)
    QBCore.Functions.Notify(message, 'error', 6000)
end)

-- Кат-сцена прилёта: игрок оказывается перед машущим Mike, камера на него.
RegisterNetEvent('bu-tutorial:client:arrival', function()
    DoScreenFadeOut(300)
    Wait(400)

    local pos = Config.Arrival.playerPos
    local found, ground = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 30.0, false)
    local z = found and ground or pos.z

    SetEntityCoords(PlayerPedId(), pos.x, pos.y, z)
    SetEntityHeading(PlayerPedId(), pos.w)
    FreezeEntityPosition(PlayerPedId(), true)

    PlaySoundFrontend(-1, 'FLIGHT_SCHOOL_LESSON_PASSED', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    SendNUIMessage({ type = 'bu:tutorial:arrival', show = true, flight = Config.Arrival.flight })
    DoScreenFadeIn(1200)
    Wait(2500)

    -- Небольшой наезд камеры на Mike
    if npc and DoesEntityExist(npc) then
        local npcCoords = GetEntityCoords(npc)
        local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x + 1.0, pos.y + 1.0, z + 1.6, 0.0, 0.0, 0.0, 50.0, false, 0)
        PointCamAtCoord(cam, npcCoords.x, npcCoords.y, npcCoords.z + 1.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1500, true, true)
        Wait(Config.Arrival.camera.holdMs)
        RenderScriptCams(false, true, 1200, true, true)
        DestroyCam(cam, true)
    end

    FreezeEntityPosition(PlayerPedId(), false)
    SendNUIMessage({ type = 'bu:tutorial:arrival', show = false })
end)

RegisterNUICallback('advance', function(_, cb)
    TriggerServerEvent('bu-tutorial:server:advance')
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
