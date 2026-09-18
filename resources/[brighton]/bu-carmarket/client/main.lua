local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openMarket()
    if open then return end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end

RegisterCommand('carmarket', openMarket)

RegisterNUICallback('getListings', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-carmarket:server:getListings', function(list)
        SendNUIMessage({ action = 'listings', list = list })
        cb('ok')
    end)
end)

RegisterNUICallback('getMy', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-carmarket:server:getMy', function(list)
        SendNUIMessage({ action = 'mine', list = list })
        cb('ok')
    end)
end)

RegisterNUICallback('list', function(data, cb)
    TriggerServerEvent('bu-carmarket:server:list', data.plate, data.price)
    cb('ok')
end)

RegisterNUICallback('unlist', function(data, cb)
    TriggerServerEvent('bu-carmarket:server:unlist', data.plate)
    cb('ok')
end)

RegisterNUICallback('buy', function(data, cb)
    TriggerServerEvent('bu-carmarket:server:buy', tonumber(data.id))
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    open = false
    SetNuiFocus(false, false)
    cb('ok')
end)

CreateThread(function()
    while true do
        if open and IsControlJustPressed(0, 202) then
            open = false
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'close' })
        end
        Wait(0)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    exports['bu-interact']:addPoint(Config.Spot.coords, 1.5, {
        label = Config.Spot.label,
        size = 1.0,
        color = { 47, 143, 131, 150 },
        action = openMarket
    })
    exports['bu-interact']:addBlip(Config.Spot.coords, {
        sprite = 225, color = 2, scale = 0.7, name = Config.Spot.label, shortRange = false
    })
end)
