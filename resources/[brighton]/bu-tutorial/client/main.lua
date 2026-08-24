local QBCore = exports['qb-core']:GetCoreObject()

local npc = nil
local spawned = false

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
    if spawned then return end
    local model = Config.NPC.model
    local coords = Config.NPC.coords

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    npc = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, false)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, Config.NPC.scenario, 0, true)

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.NPC.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.NPC.blip.scale)
    SetBlipColour(blip, Config.NPC.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.NPC.blip.name)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                icon = 'fas fa-handshake',
                label = Config.TargetLabel,
                action = function()
                    openTutorial()
                end
            }
        },
        distance = 2.5
    })

    spawned = true
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnNpc()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    spawnNpc()
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

-- Кат-сцена прилёта: показывается один раз при создании персонажа (спавн в аэропорту)
RegisterNetEvent('bu-tutorial:client:arrival', function()
    DoScreenFadeOut(400)
    Wait(600)
    SendNUIMessage({ type = 'bu:tutorial:arrival', show = true })
    PlaySoundFrontend(-1, '5_SEC_WARNING', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    DoScreenFadeIn(1500)
    Wait(9000)
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
