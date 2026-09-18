local QBCore = exports['qb-core']:GetCoreObject()

local spawned = false
local menuOpen = false

local function closeMenu()
    if not menuOpen then return end
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'bu:rental:close' })
end

local function openMenu()
    QBCore.Functions.TriggerCallback('bu-rental:server:getVehicles', function(data)
        if not data then return end
        menuOpen = true
        SendNUIMessage({ type = 'bu:rental:open', data = data })
        SetNuiFocus(true, true)
    end)
end

local function spawnStand()
    if spawned then return end

    exports['bu-interact']:spawnPed(Config.Stand.model, Config.Stand.coords, {
        label = Config.TargetLabel,
        hint = 'Арендовать транспорт',
        plate = { text = Config.TargetLabel, range = 22.0 },
        scenario = Config.Stand.scenario,
        blip = Config.Stand.blip,
        action = openMenu
    })

    -- Точка возврата убрана: возврат доступен через NPC (кнопка в меню)
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

-- ESC закрывает меню даже когда NuiFocus перехватывает клавиши
CreateThread(function()
    while true do
        Wait(0)
        if menuOpen and IsControlJustPressed(0, 202) then
            closeMenu()
        end
    end
end)

RegisterNUICallback('rent', function(data, cb)
    closeMenu()
    TriggerServerEvent('bu-rental:server:rent', data.vehicleId, data.hours, data.payment)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    closeMenu()
    cb('ok')
end)

RegisterNUICallback('return', function(_, cb)
    closeMenu()
    TriggerServerEvent('bu-rental:server:returnVehicle')
    cb('ok')
end)
