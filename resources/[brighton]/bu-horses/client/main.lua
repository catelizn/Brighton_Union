local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openTote()
    if open then return end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end

local function closeTote()
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterCommand('horses', function() openTote() end)

RegisterNUICallback('getState', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-horses:server:getState', function(state)
        SendNUIMessage({ action = 'state', state = state })
        cb('ok')
    end)
end)

RegisterNUICallback('bet', function(data, cb)
    TriggerServerEvent('bu-horses:server:placeBet', tonumber(data.horse), tonumber(data.amount))
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    closeTote()
    cb('ok')
end)

RegisterNetEvent('bu-horses:client:startRace', function()
    SendNUIMessage({ action = 'race' })
end)

RegisterNetEvent('bu-horses:client:reset', function()
    SendNUIMessage({ action = 'reset' })
end)

CreateThread(function()
    while true do
        if open and IsControlJustPressed(0, 202) then
            closeTote()
        end
        Wait(0)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if Config.Spot then
        exports['bu-interact']:addPoint(Config.Spot.coords, 1.5, {
            label = Config.Spot.label,
            size = 1.0,
            color = { 214, 153, 6, 150 },
            action = openTote
        })
        exports['bu-interact']:addBlip(Config.Spot.coords, {
            sprite = 1, color = 1, scale = 0.7, name = Config.Spot.label, shortRange = false
        })
    end
end)
