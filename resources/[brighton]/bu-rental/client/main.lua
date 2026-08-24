local QBCore = exports['qb-core']:GetCoreObject()

local spawned = false

local function openMenu()
    QBCore.Functions.TriggerCallback('bu-rental:server:getVehicles', function(data)
        if not data then return end
        SendNUIMessage({ type = 'bu:rental:open', data = data })
        SetNuiFocus(true, true)
    end)
end

local function spawnStand()
    if spawned then return end
    local model = Config.Stand.model
    local coords = Config.Stand.coords

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, Config.Stand.scenario, 0, true)

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Stand.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Stand.blip.scale)
    SetBlipColour(blip, Config.Stand.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Stand.blip.name)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                icon = 'fas fa-car-side',
                label = Config.TargetLabel,
                action = function()
                    openMenu()
                end
            },
            {
                icon = 'fas fa-undo-alt',
                label = Config.ReturnLabel,
                action = function()
                    TriggerServerEvent('bu-rental:server:returnVehicle')
                end
            }
        },
        distance = 2.5
    })

    spawned = true
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', spawnStand)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    spawnStand()
end)

RegisterNetEvent('bu-rental:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

RegisterNUICallback('rent', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('bu-rental:server:rent', data.vehicleId, data.hours, data.payment)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
